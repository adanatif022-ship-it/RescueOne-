import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/osm_place.dart';
import 'hospital_data.dart';
import 'osm_places_service.dart';
import 'places_cache.dart';
import 'storage_service.dart';

/// Real police stations, fire stations and pharmacies near the user, from
/// OpenStreetMap - used by the "Nearby assistance" screen. (The report's
/// version showed made-up places at fixed offsets; these are real.)
class NearbyServicesRepository extends ChangeNotifier {
  NearbyServicesRepository({
    OsmPlacesService? placesService,
    StorageService? storage,
    DateTime Function()? clock,
  }) : _service = placesService ?? OsmPlacesService(),
       _cache = storage == null ? null : PlacesCache(storage, _cacheKey),
       _now = clock ?? DateTime.now;

  static const _cacheKey = 'nearby_services_cache_v1';
  static const kinds = {
    OsmPlaceKind.police,
    OsmPlaceKind.fireStation,
    OsmPlaceKind.pharmacy,
  };

  final OsmPlacesService _service;
  final PlacesCache? _cache;
  final DateTime Function() _now;

  List<OsmPlace> _places = [];
  double? _dataLat;
  double? _dataLng;
  DateTime? _fetchedAt;
  bool _loading = false;
  bool _usingSavedData = false;
  String? _errorKey;
  Future<void>? _inFlight;

  bool get isLoading => _loading;
  String? get errorKey => _errorKey;
  DateTime? get fetchedAt => _fetchedAt;
  bool get usingSavedData => _usingSavedData && _places.isNotEmpty;
  List<OsmPlace> get places => List.unmodifiable(_places);

  Future<void> loadCache() async {
    final cached = await _cache?.load();
    if (cached == null || _places.isNotEmpty) return;
    _places = cached.places;
    _dataLat = cached.latitude;
    _dataLng = cached.longitude;
    _fetchedAt = cached.fetchedAt;
    _usingSavedData = true;
    notifyListeners();
  }

  /// Downloads around ([lat], [lng]) unless fresh data for roughly the
  /// same spot is already loaded.
  Future<void> ensureLoaded(double lat, double lng, {bool force = false}) {
    final movedKm = _dataLat == null
        ? double.infinity
        : haversineKm(_dataLat!, _dataLng!, lat, lng);
    final fresh =
        !_usingSavedData &&
        _places.isNotEmpty &&
        movedKm < 1 &&
        _fetchedAt != null &&
        _now().difference(_fetchedAt!) < const Duration(hours: 6);
    if (fresh && !force) return Future.value();
    if (_inFlight != null) return _inFlight!;
    return _inFlight = _download(lat, lng).whenComplete(() => _inFlight = null);
  }

  Future<void> _download(double lat, double lng) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _service.fetch(lat: lat, lng: lng, kinds: kinds);
      if (result.isSuccess) {
        _places = result.places;
        _dataLat = lat;
        _dataLng = lng;
        _fetchedAt = _now();
        _usingSavedData = false;
        _errorKey = null;
        unawaited(
          _cache?.save(
            CachedPlaces(
              latitude: lat,
              longitude: lng,
              fetchedAt: _fetchedAt!,
              places: _places,
            ),
          ),
        );
      } else {
        _errorKey = result.errorKey;
        if (_places.isNotEmpty) _usingSavedData = true;
      }
    } catch (_) {
      _errorKey = 'network_error';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> clearSavedData() async {
    _places = [];
    _dataLat = _dataLng = null;
    _fetchedAt = null;
    _usingSavedData = false;
    _errorKey = null;
    await _cache?.clear();
    notifyListeners();
  }
}
