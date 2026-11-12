/// Kinds of real places fetched from OpenStreetMap.
enum OsmPlaceKind { hospital, clinic, police, fireStation, pharmacy }

/// A raw, real place from OpenStreetMap (Overpass or Nominatim), before
/// any app-specific estimates are added. Fields OSM doesn't have stay null.
class OsmPlace {
  /// Stable OSM reference such as `node/123` or `way/456`.
  final String id;
  final OsmPlaceKind kind;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? website;
  final String? emergencyTag;
  final String? openingHours;

  const OsmPlace({
    required this.id,
    required this.kind,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.nameEn,
    this.nameAr,
    this.address,
    this.phone,
    this.website,
    this.emergencyTag,
    this.openingHours,
  });

  String displayName({required bool arabic}) =>
      (arabic ? nameAr : nameEn) ?? name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'name': name,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'lat': latitude,
    'lng': longitude,
    'address': address,
    'phone': phone,
    'website': website,
    'emergency': emergencyTag,
    'hours': openingHours,
  };

  static OsmPlace? tryFromJson(Map<String, dynamic> json) {
    final kind = OsmPlaceKind.values.asNameMap()[json['kind']];
    if (kind == null) return null;
    return OsmPlace(
      id: json['id'] as String,
      kind: kind,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      nameAr: json['nameAr'] as String?,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      emergencyTag: json['emergency'] as String?,
      openingHours: json['hours'] as String?,
    );
  }
}
