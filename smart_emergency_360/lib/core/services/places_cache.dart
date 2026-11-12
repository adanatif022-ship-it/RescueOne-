import '../models/osm_place.dart';
import 'storage_service.dart';

/// The last successful download of nearby places, with where and when it
/// was fetched - shown immediately on the next launch and kept on screen
/// when the network fails, instead of an empty list.
class CachedPlaces {
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;
  final List<OsmPlace> places;

  const CachedPlaces({
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
    required this.places,
  });
}

class PlacesCache {
  PlacesCache(this._storage, this.key);

  final StorageService _storage;
  final String key;

  Future<CachedPlaces?> load() async {
    final raw = await _storage.readJson(key);
    if (raw is! Map) return null;
    try {
      final places = <OsmPlace>[
        for (final p in (raw['places'] as List? ?? const []))
          if (p is Map) ?OsmPlace.tryFromJson(Map<String, dynamic>.from(p)),
      ];
      if (places.isEmpty) return null;
      return CachedPlaces(
        latitude: (raw['lat'] as num).toDouble(),
        longitude: (raw['lng'] as num).toDouble(),
        fetchedAt: DateTime.parse(raw['fetchedAt'] as String),
        places: places,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CachedPlaces data) => _storage.saveJson(key, {
    'lat': data.latitude,
    'lng': data.longitude,
    'fetchedAt': data.fetchedAt.toIso8601String(),
    'places': data.places.map((p) => p.toJson()).toList(),
  });

  Future<void> clear() => _storage.remove(key);
}
