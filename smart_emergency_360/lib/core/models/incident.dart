import 'hospital.dart';

enum IncidentType { medical, fire, accident, danger, security, other }

enum AlertMode { normal, silent }

enum IncidentStatus {
  created,
  sent,
  received,
  assigned,
  helpOnWay,
  assisted,
  closed,
  // Terminal state outside the normal linear timeline - not part of
  // incidentStatusOrder, set only via IncidentRepository.cancelIncident.
  cancelled,
}

extension IncidentStatusStep on IncidentStatus {
  int get step => IncidentStatus.values.indexOf(this);

  bool get isOpen =>
      this != IncidentStatus.closed &&
      this != IncidentStatus.cancelled &&
      this != IncidentStatus.assisted;

  bool get isFinished =>
      this == IncidentStatus.assisted || this == IncidentStatus.closed;
}

const List<IncidentStatus> incidentStatusOrder = [
  IncidentStatus.created,
  IncidentStatus.sent,
  IncidentStatus.received,
  IncidentStatus.assigned,
  IncidentStatus.helpOnWay,
  IncidentStatus.assisted,
  IncidentStatus.closed,
];

class IncidentLocation {
  final double latitude;
  final double longitude;

  const IncidentLocation({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {'lat': latitude, 'lng': longitude};

  factory IncidentLocation.fromJson(Map<String, dynamic> json) =>
      IncidentLocation(
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lng'] as num).toDouble(),
      );
}

/// A copy of the recommended hospital taken when the incident is created,
/// so tracking/details keep showing it even after the live hospital list
/// changes (new location, app restart while offline, ...).
class HospitalSnapshot {
  final String id;
  final String nameEn;
  final String nameAr;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int travelTimeMinutes;
  final String? phone;

  const HospitalSnapshot({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.travelTimeMinutes,
    this.phone,
  });

  factory HospitalSnapshot.fromHospital(Hospital h) => HospitalSnapshot(
    id: h.id,
    nameEn: h.nameEn,
    nameAr: h.nameAr,
    latitude: h.latitude,
    longitude: h.longitude,
    distanceKm: h.distanceKm,
    travelTimeMinutes: h.travelTimeMinutes,
    phone: h.phone,
  );

  String nameFor({required bool arabic}) => arabic ? nameAr : nameEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'lat': latitude,
    'lng': longitude,
    'distanceKm': distanceKm,
    'travel': travelTimeMinutes,
    'phone': phone,
  };

  factory HospitalSnapshot.fromJson(Map<String, dynamic> json) =>
      HospitalSnapshot(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameAr: json['nameAr'] as String,
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lng'] as num).toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        travelTimeMinutes: (json['travel'] as num).toInt(),
        phone: json['phone'] as String?,
      );
}

class Incident {
  final String id;
  final IncidentType type;
  final String description;
  final AlertMode mode;
  final IncidentLocation? location;
  final DateTime createdAt;
  final IncidentStatus status;
  final String? recommendedHospitalId;
  final HospitalSnapshot? hospital;

  /// When each status was reached (shown next to the timeline steps).
  final Map<IncidentStatus, DateTime> statusTimes;

  /// Optional 1-5 rating and comment from the "Assistance completed" screen.
  final int? rating;
  final String? feedback;

  const Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.mode,
    required this.location,
    required this.createdAt,
    required this.status,
    this.recommendedHospitalId,
    this.hospital,
    this.statusTimes = const {},
    this.rating,
    this.feedback,
  });

  Incident copyWith({
    IncidentStatus? status,
    String? recommendedHospitalId,
    HospitalSnapshot? hospital,
    Map<IncidentStatus, DateTime>? statusTimes,
    int? rating,
    String? feedback,
  }) {
    return Incident(
      id: id,
      type: type,
      description: description,
      mode: mode,
      location: location,
      createdAt: createdAt,
      status: status ?? this.status,
      recommendedHospitalId:
          recommendedHospitalId ?? this.recommendedHospitalId,
      hospital: hospital ?? this.hospital,
      statusTimes: statusTimes ?? this.statusTimes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'description': description,
    'mode': mode.name,
    'location': location?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'recommendedHospitalId': recommendedHospitalId,
    'hospital': hospital?.toJson(),
    'statusTimes': {
      for (final e in statusTimes.entries)
        e.key.name: e.value.toIso8601String(),
    },
    'rating': rating,
    'feedback': feedback,
  };

  factory Incident.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['statusTimes'];
    final times = <IncidentStatus, DateTime>{};
    if (rawTimes is Map) {
      final byName = IncidentStatus.values.asNameMap();
      rawTimes.forEach((key, value) {
        final status = byName[key];
        final time = value is String ? DateTime.tryParse(value) : null;
        if (status != null && time != null) times[status] = time;
      });
    }
    final createdAt = DateTime.parse(json['createdAt'] as String);
    times.putIfAbsent(IncidentStatus.created, () => createdAt);

    return Incident(
      id: json['id'] as String,
      type: IncidentType.values.byName(json['type'] as String),
      description: json['description'] as String? ?? '',
      mode: AlertMode.values.byName(json['mode'] as String),
      location: json['location'] != null
          ? IncidentLocation.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null,
      createdAt: createdAt,
      status: IncidentStatus.values.byName(json['status'] as String),
      recommendedHospitalId: json['recommendedHospitalId'] as String?,
      hospital: json['hospital'] is Map
          ? HospitalSnapshot.fromJson(
              Map<String, dynamic>.from(json['hospital'] as Map),
            )
          : null,
      statusTimes: times,
      rating: (json['rating'] as num?)?.toInt(),
      feedback: json['feedback'] as String?,
    );
  }
}
