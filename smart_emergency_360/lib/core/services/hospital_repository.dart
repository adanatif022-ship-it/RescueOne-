import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/hospital.dart';
import '../models/incident.dart';
import '../models/osm_place.dart';
import 'hospital_data.dart';
import 'hospital_ranking.dart' as ranking;
import 'location_service.dart';
import 'osm_places_service.dart';
import 'places_cache.dart';
import 'storage_service.dart';

enum HospitalLoadStatus { idle, loading, ready }

/// Holds the real nearby hospitals/clinics (OpenStreetMap - see
/// [OsmPlacesService]) around the user's current location and exposes the
/// Smart Hospital Routing recommendation (see hospital_ranking.dart).
///
/// The last successful download is saved on the device: it is shown
/// immediately on the next launch and stays on screen (clearly labeled
/// with its time) whenever a refresh fails, instead of an empty list.
/// Nothing is ever invented: with no real data at all, the list is empty
/// and the UI explains why with a retry button.
class HospitalRepository extends ChangeNotifier {
  HospitalRepository(
    this._locationService, {
    OsmPlacesService? placesService,
    StorageService? storage,
    DateTime Function()? clock,
  }) : _placesService = placesService ?? OsmPlacesService(),
       _cache = storage == null ? null : PlacesCache(storage, _cacheKey),
       _now = clock ?? DateTime.now;

  static const _cacheKey = 'hospital_cache_v1';

  /// Minimum gap between automatic refreshes, so rebuilds or double taps
  /// can't hammer the free OpenStreetMap services. `force` bypasses it.
  static const _minRefreshGap = Duration(seconds: 8);

  /// Saved results further than this from the user are not relevant.
  static const _maxSavedDataDistanceKm = 30.0;

  /// A new fix this far from the last download triggers a new download.
  static const _refetchDistanceKm = 1.0;

  final LocationService _locationService;
  final OsmPlacesService _placesService;
  final PlacesCache? _cache;
  final DateTime Function() _now;

  double _lat = AppConfig.defaultLatitude;
  double _lng = AppConfig.defaultLongitude;
  bool _hasRealFix = false;
  double? _accuracyMeters;
  bool _approximateOnly = false;
  HospitalLoadStatus _status = HospitalLoadStatus.idle;
  String? _locationErrorKey;
  String? _dataErrorKey;

  List<OsmPlace> _rawPlaces = [];
  List<Hospital> _hospitals = [];
  double? _dataLat;
  double? _dataLng;
  DateTime? _dataFetchedAt;
  bool _usingSavedData = false;

  DateTime? _lastRefreshAt;
  Future<void>? _inFlight;

  bool get hasRealFix => _hasRealFix;

  /// How close the current fix is to the real position, in metres.
  double? get accuracyMeters => _hasRealFix ? _accuracyMeters : null;

  /// The user allowed only approximate location (can be km off).
  bool get approximateOnly => _hasRealFix && _approximateOnly;
  HospitalLoadStatus get status => _status;
  bool get isLoading => _status == HospitalLoadStatus.loading;
  bool get hasStarted => _status != HospitalLoadStatus.idle;
  String? get locationErrorKey => _locationErrorKey;

  /// Why the last download failed (`timeout`, `server_error`, ...).
  String? get overpassErrorKey => _dataErrorKey;
  double get currentLat => _lat;
  double get currentLng => _lng;
  List<Hospital> get hospitals => List.unmodifiable(_hospitals);

  /// When the shown hospital data was downloaded.
  DateTime? get dataFetchedAt => _dataFetchedAt;

  /// True when the list comes from a previous session/download because
  /// a fresh one hasn't succeeded (yet).
  bool get usingSavedData => _usingSavedData && _hospitals.isNotEmpty;

  /// Loads the last saved download (called once at startup).
  Future<void> loadCache() async {
    final cached = await _cache?.load();
    if (cached == null || _rawPlaces.isNotEmpty) return;
    _rawPlaces = cached.places;
    _dataLat = cached.latitude;
    _dataLng = cached.longitude;
    _dataFetchedAt = cached.fetchedAt;
    _usingSavedData = true;
    _lat = cached.latitude;
    _lng = cached.longitude;
    _rebuild();
    _status = HospitalLoadStatus.ready;
    notifyListeners();
  }

  /// Gets a fresh GPS fix, then downloads nearby hospitals around it.
  Future<void> refresh({bool force = false}) {
    if (_inFlight != null) return _inFlight!;
    if (!force &&
        _lastRefreshAt != null &&
        _now().difference(_lastRefreshAt!) < _minRefreshGap) {
      return Future.value();
    }
    _lastRefreshAt = _now();
    return _inFlight = _refreshNow().whenComplete(() => _inFlight = null);
  }

  Future<void> _refreshNow() async {
    _status = HospitalLoadStatus.loading;
    notifyListeners();

    LocationResult location;
    try {
      location = await _locationService.getCurrentLocation();
    } catch (_) {
      location = const LocationResult.failure('unknown_error');
    }
    if (!location.hasLocation) {
      // Keep any saved data on screen and surface the location error.
      _hasRealFix = false;
      _locationErrorKey = location.errorKey ?? 'unknown_error';
      _status = HospitalLoadStatus.ready;
      notifyListeners();
      return;
    }
    _locationErrorKey = null;
    _accuracyMeters = location.accuracyMeters;
    _approximateOnly = location.approximateOnly;
    await _downloadAround(location.latitude!, location.longitude!);
  }

  /// Reuses a fix another screen already obtained (e.g. the SOS screen),
  /// so the recommendation is computed around the incident location
  /// without asking for GPS twice. Downloads only when needed.
  Future<void> useLocation(
    double lat,
    double lng, {
    double? accuracyMeters,
    bool approximateOnly = false,
  }) {
    final movedKm = _dataLat == null
        ? double.infinity
        : haversineKm(_dataLat!, _dataLng!, lat, lng);
    _lat = lat;
    _lng = lng;
    _hasRealFix = true;
    _accuracyMeters = accuracyMeters;
    _approximateOnly = approximateOnly;
    _locationErrorKey = null;
    final needsDownload =
        _rawPlaces.isEmpty || _usingSavedData || movedKm > _refetchDistanceKm;
    if (!needsDownload) {
      _rebuild();
      notifyListeners();
      return Future.value();
    }
    if (_inFlight != null) return _inFlight!;
    _lastRefreshAt = _now();
    _status = HospitalLoadStatus.loading;
    notifyListeners();
    return _inFlight = _downloadAround(
      lat,
      lng,
    ).whenComplete(() => _inFlight = null);
  }

  Future<void> _downloadAround(double lat, double lng) async {
    _lat = lat;
    _lng = lng;
    _hasRealFix = true;

    if (_dataLat != null &&
        haversineKm(_dataLat!, _dataLng!, lat, lng) > _maxSavedDataDistanceKm) {
      _rawPlaces = [];
      _dataLat = _dataLng = null;
      _dataFetchedAt = null;
    }
    _rebuild();

    try {
      final result = await _placesService.fetch(
        lat: lat,
        lng: lng,
        kinds: const {OsmPlaceKind.hospital, OsmPlaceKind.clinic},
      );
      if (result.isSuccess) {
        _rawPlaces = result.places;
        _dataLat = lat;
        _dataLng = lng;
        _dataFetchedAt = _now();
        _usingSavedData = false;
        _dataErrorKey = null;
        unawaited(
          _cache?.save(
            CachedPlaces(
              latitude: lat,
              longitude: lng,
              fetchedAt: _dataFetchedAt!,
              places: _rawPlaces,
            ),
          ),
        );
      } else {
        _dataErrorKey = result.errorKey;
        if (_rawPlaces.isNotEmpty) _usingSavedData = true;
      }
    } catch (_) {
      _dataErrorKey = 'network_error';
      if (_rawPlaces.isNotEmpty) _usingSavedData = true;
    }
    _rebuild();
    _status = HospitalLoadStatus.ready;
    notifyListeners();
  }

  void _rebuild() {
    final now = _now();
    _hospitals =
        _rawPlaces
            .where(
              (p) =>
                  p.kind == OsmPlaceKind.hospital ||
                  p.kind == OsmPlaceKind.clinic,
            )
            .map((p) => hospitalFromPlace(p, _lat, _lng, now))
            .toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  /// Smart recommendation for a specific incident type.
  Hospital? recommendationFor(IncidentType type) =>
      ranking.recommendHospital(_hospitals, type);

  /// Default recommendation (for a medical emergency).
  Hospital? get topRecommendation => recommendationFor(IncidentType.medical);

  List<String> recommendationReasonKeys(
    Hospital recommended, [
    IncidentType type = IncidentType.medical,
  ]) => ranking.recommendationReasonKeys(recommended, _hospitals, type);

  Hospital? byId(String id) {
    for (final h in _hospitals) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// Forgets downloaded and saved data (Settings > Delete all data).
  Future<void> clearSavedData() async {
    _rawPlaces = [];
    _hospitals = [];
    _dataLat = _dataLng = null;
    _dataFetchedAt = null;
    _usingSavedData = false;
    _dataErrorKey = null;
    await _cache?.clear();
    notifyListeners();
  }
}
