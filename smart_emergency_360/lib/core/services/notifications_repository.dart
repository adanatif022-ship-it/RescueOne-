import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/incident.dart';
import 'storage_service.dart';

/// In-app notification center: every incident status change is recorded
/// here (bell icon on Home). [onNew] lets the app root show a banner for
/// each new one while notifications are enabled in Settings.
class NotificationsRepository extends ChangeNotifier {
  NotificationsRepository(this._storage);

  static const _key = 'notifications';
  static const _maxItems = 60;
  final StorageService _storage;
  int _seq = 0;

  List<AppNotification> _items = [];
  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  /// Called for every newly added notification.
  void Function(AppNotification notification)? onNew;

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is List) {
      _items = [
        for (final e in raw)
          if (e is Map)
            ?AppNotification.tryFromJson(Map<String, dynamic>.from(e)),
      ];
      notifyListeners();
    }
  }

  Future<void> _persist() =>
      _storage.saveJson(_key, _items.map((n) => n.toJson()).toList());

  Future<void> addForIncident(Incident incident, IncidentStatus status) async {
    final notification = AppNotification(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      incidentId: incident.id,
      incidentType: incident.type,
      status: status,
      time: DateTime.now(),
    );
    _items.insert(0, notification);
    if (_items.length > _maxItems) _items = _items.sublist(0, _maxItems);
    notifyListeners();
    onNew?.call(notification);
    await _persist();
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    _items = _items.map((n) => n.read ? n : n.markRead()).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> removeForIncident(String incidentId) async {
    final before = _items.length;
    _items = _items.where((n) => n.incidentId != incidentId).toList();
    if (_items.length == before) return;
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _storage.remove(_key);
  }
}
