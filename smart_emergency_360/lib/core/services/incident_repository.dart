import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/hospital.dart';
import '../models/incident.dart';
import 'notifications_repository.dart';
import 'storage_service.dart';

/// Holds the incident list and simulates status progression.
///
/// There is no backend: creating an incident stores it locally and a timer
/// advances its status every [stepInterval] up to "help on the way", to
/// demonstrate tracking. Nothing here contacts a real dispatch system -
/// the real emergency call stays a separate, explicit user action.
class IncidentRepository extends ChangeNotifier {
  IncidentRepository(
    this._storage, {
    this.notifications,
    this.stepInterval = const Duration(seconds: 4),
  });

  static const _key = 'incidents';
  final StorageService _storage;
  final NotificationsRepository? notifications;
  final Duration stepInterval;
  final Map<String, Timer> _timers = {};

  List<Incident> _incidents = [];
  List<Incident> get incidents => List.unmodifiable(_incidents);

  /// The newest incident that is still in progress (not yet assisted,
  /// closed or cancelled).
  Incident? get activeIncident {
    for (final i in _incidents) {
      if (i.status.isOpen) return i;
    }
    return null;
  }

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is List) {
      _incidents = [];
      for (final e in raw) {
        if (e is! Map) continue;
        try {
          _incidents.add(Incident.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {
          // Skip a corrupted record instead of losing the whole history.
        }
      }
      notifyListeners();
      // Resume progress for incidents still open when the app last closed,
      // so they don't stay frozen forever after a restart.
      for (final incident in _incidents) {
        if (incident.status.isOpen) _resumeAutoProgress(incident.id);
      }
    }
  }

  Future<void> _persist() async {
    await _storage.saveJson(_key, _incidents.map((i) => i.toJson()).toList());
  }

  Future<Incident> createIncident({
    required IncidentType type,
    required String description,
    required AlertMode mode,
    required IncidentLocation? location,
    Hospital? recommendedHospital,
  }) async {
    final now = DateTime.now();
    final incident = Incident(
      id: _generateFriendlyId(),
      type: type,
      description: description,
      mode: mode,
      location: location,
      createdAt: now,
      status: IncidentStatus.created,
      recommendedHospitalId: recommendedHospital?.id,
      hospital: recommendedHospital == null
          ? null
          : HospitalSnapshot.fromHospital(recommendedHospital),
      statusTimes: {IncidentStatus.created: now},
    );
    _incidents.insert(0, incident);
    notifyListeners();
    await _persist();
    unawaited(notifications?.addForIncident(incident, IncidentStatus.created));
    _resumeAutoProgress(incident.id);
    return incident;
  }

  /// Advances [id] one step at a time toward `helpOnWay`, resuming from
  /// whatever status it currently has.
  void _resumeAutoProgress(String id) {
    _timers[id]?.cancel();
    _timers[id] = Timer.periodic(stepInterval, (timer) {
      final incident = byId(id);
      final currentIdx = incident == null
          ? -1
          : incidentStatusOrder.indexOf(incident.status);
      final targetIdx = incidentStatusOrder.indexOf(IncidentStatus.helpOnWay);
      if (currentIdx == -1 || currentIdx >= targetIdx) {
        timer.cancel();
        _timers.remove(id);
        return;
      }
      updateStatus(id, incidentStatusOrder[currentIdx + 1]);
    });
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final current = _incidents[index];
    if (current.status == status) return;
    if (!status.isOpen) {
      _timers.remove(id)?.cancel();
    }
    final updated = current.copyWith(
      status: status,
      statusTimes: {...current.statusTimes, status: DateTime.now()},
    );
    _incidents[index] = updated;
    notifyListeners();
    await _persist();
    unawaited(notifications?.addForIncident(updated, status));
  }

  Future<void> advanceToNextStage(String id) async {
    final incident = byId(id);
    if (incident == null) return;
    final currentIdx = incidentStatusOrder.indexOf(incident.status);
    if (currentIdx == -1) return; // not on the linear timeline (cancelled)
    if (currentIdx < incidentStatusOrder.length - 1) {
      await updateStatus(id, incidentStatusOrder[currentIdx + 1]);
    }
  }

  /// Cancels an incident - a terminal state outside the normal timeline.
  /// Also stops its simulated auto-progress timer.
  Future<void> cancelIncident(String id) async {
    _timers.remove(id)?.cancel();
    await updateStatus(id, IncidentStatus.cancelled);
  }

  /// Attaches the recommended hospital to an incident that was created
  /// before any hospital data was available (e.g. alert sent offline).
  Future<void> attachHospitalIfMissing(String id, Hospital hospital) async {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final incident = _incidents[index];
    if (incident.hospital != null || !incident.status.isOpen) return;
    _incidents[index] = incident.copyWith(
      recommendedHospitalId: hospital.id,
      hospital: HospitalSnapshot.fromHospital(hospital),
    );
    notifyListeners();
    await _persist();
  }

  /// Saves the optional rating/comment from the Assistance Completed screen.
  Future<void> rateIncident(String id, int rating, String feedback) async {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _incidents[index] = _incidents[index].copyWith(
      rating: rating.clamp(1, 5),
      feedback: feedback.trim(),
    );
    notifyListeners();
    await _persist();
  }

  /// Readable reference (e.g. INC-2026-001) instead of a raw UUID.
  String _generateFriendlyId() {
    final year = DateTime.now().year;
    var seq = _incidents.length + 1;
    String candidate;
    do {
      candidate = 'INC-$year-${seq.toString().padLeft(3, '0')}';
      seq++;
    } while (_incidents.any((i) => i.id == candidate));
    return candidate;
  }

  Incident? byId(String id) {
    for (final i in _incidents) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Removes one finished incident from the history (open incidents must
  /// be cancelled first) and its notifications.
  Future<void> deleteIncident(String id) async {
    final incident = byId(id);
    if (incident == null || incident.status.isOpen) return;
    _timers.remove(id)?.cancel();
    _incidents.removeWhere((i) => i.id == id);
    notifyListeners();
    await _persist();
    await notifications?.removeForIncident(id);
  }

  /// Deletes every incident (Settings > Delete all data).
  Future<void> clear() async {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _incidents = [];
    notifyListeners();
    await _storage.remove(_key);
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
