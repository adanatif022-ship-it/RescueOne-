import 'incident.dart';

/// One entry in the in-app notification center (bell icon on Home).
/// Created automatically whenever an incident changes status.
class AppNotification {
  final String id;
  final String incidentId;
  final IncidentType incidentType;
  final IncidentStatus status;
  final DateTime time;
  final bool read;

  const AppNotification({
    required this.id,
    required this.incidentId,
    required this.incidentType,
    required this.status,
    required this.time,
    this.read = false,
  });

  AppNotification markRead() => AppNotification(
    id: id,
    incidentId: incidentId,
    incidentType: incidentType,
    status: status,
    time: time,
    read: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'incidentId': incidentId,
    'type': incidentType.name,
    'status': status.name,
    'time': time.toIso8601String(),
    'read': read,
  };

  static AppNotification? tryFromJson(Map<String, dynamic> json) {
    final type = IncidentType.values.asNameMap()[json['type']];
    final status = IncidentStatus.values.asNameMap()[json['status']];
    final time = DateTime.tryParse(json['time'] as String? ?? '');
    if (type == null || status == null || time == null) return null;
    return AppNotification(
      id: json['id'] as String,
      incidentId: json['incidentId'] as String,
      incidentType: type,
      status: status,
      time: time,
      read: json['read'] as bool? ?? false,
    );
  }
}
