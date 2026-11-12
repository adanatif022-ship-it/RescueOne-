import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_place.dart';
import 'storage_service.dart';

/// Places the user saved (home, work, a hospital...), stored on-device.
class SavedPlacesRepository extends ChangeNotifier {
  SavedPlacesRepository(this._storage);

  static const _key = 'saved_places';
  final StorageService _storage;

  List<SavedPlace> _places = [];
  List<SavedPlace> get places => List.unmodifiable(_places);

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is List) {
      _places = [
        for (final e in raw)
          if (e is Map) SavedPlace.fromJson(Map<String, dynamic>.from(e)),
      ];
      notifyListeners();
    }
  }

  Future<void> _persist() =>
      _storage.saveJson(_key, _places.map((p) => p.toJson()).toList());

  bool isSaved(double lat, double lng) => _places.any(
    (p) =>
        (p.latitude - lat).abs() < 0.0001 && (p.longitude - lng).abs() < 0.0001,
  );

  Future<SavedPlace> add({
    required String name,
    required double latitude,
    required double longitude,
    String? note,
  }) async {
    final place = SavedPlace(
      id: const Uuid().v4(),
      name: name.trim(),
      latitude: latitude,
      longitude: longitude,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      savedAt: DateTime.now(),
    );
    _places.insert(0, place);
    notifyListeners();
    await _persist();
    return place;
  }

  Future<void> remove(String id) async {
    _places.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _places = [];
    notifyListeners();
    await _storage.remove(_key);
  }
}
