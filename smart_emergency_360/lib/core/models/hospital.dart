enum CongestionLevel { low, moderate, high }

enum HospitalCategory { hospital, clinic }

/// A real nearby healthcare facility from OpenStreetMap, with a couple of
/// clearly-labeled simulated estimates layered on top (congestion / waiting
/// time - see hospitals_disclaimer). Every other field is either real data
/// pulled straight from OSM tags, or null when OSM simply doesn't have that
/// tag for this place - nothing here is ever fabricated to fill a gap.
class Hospital {
  final String id;
  final String nameEn;
  final String nameAr;
  final double latitude;
  final double longitude;
  final double distanceKm;

  /// Derived from the real distance above (not itself measured), so it's
  /// an estimate - but a real-distance-based one, not invented.
  final int travelTimeMinutes;

  final CongestionLevel congestion;
  final int estimatedWaitMinutes;

  final HospitalCategory category;

  /// Real one-line address built from OSM `addr:*` tags, when present.
  final String? address;

  /// Real phone number from OSM `phone`/`contact:phone`, when present.
  final String? phone;

  /// Real website from OSM `website`/`contact:website`, when present.
  final String? website;

  /// Whether this place is tagged as having an emergency department, from
  /// OSM's `emergency` tag. Null means OSM simply doesn't say either way -
  /// shown as "unknown", never guessed as yes or no.
  final bool? hasEmergencyDepartment;

  /// Raw `opening_hours` tag text, when present (e.g. "24/7").
  final String? openingHoursText;

  const Hospital({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.travelTimeMinutes,
    required this.congestion,
    required this.estimatedWaitMinutes,
    required this.category,
    this.address,
    this.phone,
    this.website,
    this.hasEmergencyDepartment,
    this.openingHoursText,
  });

  bool get isClinic => category == HospitalCategory.clinic;

  String nameFor({required bool arabic}) => arabic ? nameAr : nameEn;

  Hospital copyWith({
    double? distanceKm,
    int? travelTimeMinutes,
    CongestionLevel? congestion,
    int? estimatedWaitMinutes,
  }) {
    return Hospital(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
      congestion: congestion ?? this.congestion,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      category: category,
      address: address,
      phone: phone,
      website: website,
      hasEmergencyDepartment: hasEmergencyDepartment,
      openingHoursText: openingHoursText,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'lat': latitude,
    'lng': longitude,
    'distanceKm': distanceKm,
    'travelTimeMinutes': travelTimeMinutes,
    'congestion': congestion.name,
    'wait': estimatedWaitMinutes,
    'category': category.name,
    'address': address,
    'phone': phone,
    'website': website,
    'emergency': hasEmergencyDepartment,
    'hours': openingHoursText,
  };

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
    id: json['id'] as String,
    nameEn: json['nameEn'] as String,
    nameAr: json['nameAr'] as String,
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lng'] as num).toDouble(),
    distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    travelTimeMinutes: (json['travelTimeMinutes'] as num?)?.toInt() ?? 0,
    congestion:
        CongestionLevel.values.asNameMap()[json['congestion']] ??
        CongestionLevel.moderate,
    estimatedWaitMinutes: (json['wait'] as num?)?.toInt() ?? 0,
    category:
        HospitalCategory.values.asNameMap()[json['category']] ??
        HospitalCategory.hospital,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    website: json['website'] as String?,
    hasEmergencyDepartment: json['emergency'] as bool?,
    openingHoursText: json['hours'] as String?,
  );
}
