/// A location the user saved (home, work, a hospital...) so it can be
/// opened in Google Maps or shared quickly during an emergency.
class SavedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? note;
  final DateTime savedAt;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.savedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': latitude,
    'lng': longitude,
    'note': note,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lng'] as num).toDouble(),
    note: json['note'] as String?,
    savedAt:
        DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
