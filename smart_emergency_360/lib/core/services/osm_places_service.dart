import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/osm_place.dart';
import 'hospital_data.dart';

class OsmFetchResult {
  final List<OsmPlace> places;

  /// `no_results`, `timeout`, `server_error` or `network_error`.
  final String? errorKey;

  /// Which service answered (for debugging / the attribution line).
  final String? source;

  const OsmFetchResult.success(this.places, this.source) : errorKey = null;
  const OsmFetchResult.failure(this.errorKey)
    : places = const [],
      source = null;

  bool get isSuccess => errorKey == null;
}

typedef _Attempt = Future<OsmFetchResult> Function();

/// Fetches real places (hospitals, clinics, police, fire stations,
/// pharmacies) from OpenStreetMap - free, no API key, works on Android,
/// iOS and web (both services send permissive CORS headers).
///
/// Reliability (the report's main problem was public Overpass servers
/// failing during testing):
/// * Several Overpass mirrors are tried as a staggered race: the next one
///   starts after [stagger] - or immediately when one fails - and the
///   first successful answer wins.
/// * Nominatim (OpenStreetMap's own search service) is part of the race as
///   an independent fallback, queried at most once per second as its
///   usage policy requires.
/// * On Android/iOS an honest User-Agent is sent (overpass-api.de answers
///   406 to anonymous clients). Browsers always send their own.
class OsmPlacesService {
  OsmPlacesService({
    http.Client? client,
    this.stagger = const Duration(seconds: 5),
    this.requestTimeout = const Duration(seconds: 35),
    this.overallTimeout = const Duration(seconds: 50),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration stagger;
  final Duration requestTimeout;
  final Duration overallTimeout;

  static const overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];
  static const nominatimEndpoint = 'https://nominatim.openstreetmap.org/search';

  Map<String, String> get _headers =>
      kIsWeb ? const {} : const {'User-Agent': AppConfig.userAgent};

  Future<OsmFetchResult> fetch({
    required double lat,
    required double lng,
    required Set<OsmPlaceKind> kinds,
    int radiusMeters = AppConfig.searchRadiusMeters,
  }) {
    final query = buildOverpassQuery(lat, lng, radiusMeters, kinds);
    Future<OsmFetchResult> overpass(String endpoint) =>
        _overpass(endpoint, query, lat, lng, radiusMeters, kinds);

    return _race([
      () => overpass(overpassEndpoints[0]),
      () => overpass(overpassEndpoints[1]),
      () => _nominatim(lat, lng, radiusMeters, kinds),
      () => overpass(overpassEndpoints[2]),
      () => overpass(overpassEndpoints[3]),
    ]);
  }

  /// First success wins. A failed attempt immediately starts the next
  /// one; otherwise the next one starts after [stagger].
  Future<OsmFetchResult> _race(List<_Attempt> attempts) {
    final completer = Completer<OsmFetchResult>();
    var next = 0;
    var pending = 0;
    var lastError = 'network_error';
    Timer? staggerTimer;
    Timer? overallTimer;

    void finish(OsmFetchResult result) {
      if (completer.isCompleted) return;
      staggerTimer?.cancel();
      overallTimer?.cancel();
      completer.complete(result);
    }

    void startNext() {
      if (completer.isCompleted || next >= attempts.length) return;
      final attempt = attempts[next++];
      pending++;
      staggerTimer?.cancel();
      staggerTimer = Timer(stagger, startNext);

      void onFailure(String errorKey) {
        pending--;
        lastError = _moreInformative(lastError, errorKey);
        if (next < attempts.length) {
          startNext();
        } else if (pending == 0) {
          finish(OsmFetchResult.failure(lastError));
        }
      }

      attempt().then(
        (result) {
          if (completer.isCompleted) return;
          if (result.isSuccess) {
            finish(result);
          } else {
            onFailure(result.errorKey!);
          }
        },
        onError: (Object _) {
          if (!completer.isCompleted) onFailure('network_error');
        },
      );
    }

    overallTimer = Timer(overallTimeout, () {
      finish(OsmFetchResult.failure(_moreInformative(lastError, 'timeout')));
    });
    startNext();
    return completer.future;
  }

  static const _errorRank = {
    'network_error': 0,
    'server_error': 1,
    'timeout': 2,
    'no_results': 3,
  };

  static String _moreInformative(String a, String b) =>
      (_errorRank[b] ?? 0) > (_errorRank[a] ?? 0) ? b : a;

  // -------------------------------------------------------------- Overpass

  /// Overpass QL for the requested kinds within [radius] metres, with
  /// `out center` so ways/relations also get a coordinate.
  @visibleForTesting
  static String buildOverpassQuery(
    double lat,
    double lng,
    int radius,
    Set<OsmPlaceKind> kinds,
  ) {
    final around = '(around:$radius,$lat,$lng)';
    final filters = <String>[
      if (kinds.contains(OsmPlaceKind.hospital)) ...[
        '["amenity"="hospital"]',
        '["healthcare"="hospital"]',
      ],
      if (kinds.contains(OsmPlaceKind.clinic)) ...[
        '["amenity"="clinic"]',
        '["healthcare"="clinic"]',
      ],
      if (kinds.contains(OsmPlaceKind.police)) '["amenity"="police"]',
      if (kinds.contains(OsmPlaceKind.fireStation))
        '["amenity"="fire_station"]',
      if (kinds.contains(OsmPlaceKind.pharmacy)) ...[
        '["amenity"="pharmacy"]',
        '["healthcare"="pharmacy"]',
      ],
    ];
    final body = filters.map((f) => 'nwr$f$around;').join();
    return '[out:json][timeout:25];($body);out center tags;';
  }

  Future<OsmFetchResult> _overpass(
    String endpoint,
    String query,
    double lat,
    double lng,
    int radius,
    Set<OsmPlaceKind> kinds,
  ) async {
    try {
      final response = await _client
          .post(Uri.parse(endpoint), headers: _headers, body: {'data': query})
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        debugPrint('[OSM] $endpoint -> HTTP ${response.statusCode}');
        return const OsmFetchResult.failure('server_error');
      }
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final elements = (body is Map ? body['elements'] as List? : null) ?? [];
      final places = <OsmPlace>[];
      for (final raw in elements) {
        if (raw is! Map) continue;
        final place = parseOverpassElement(
          Map<String, dynamic>.from(raw),
          kinds,
        );
        if (place != null) places.add(place);
      }
      return _finish(places, lat, lng, radius, Uri.parse(endpoint).host);
    } on TimeoutException {
      debugPrint('[OSM] $endpoint timed out');
      return const OsmFetchResult.failure('timeout');
    } catch (e) {
      debugPrint('[OSM] $endpoint failed: $e');
      return const OsmFetchResult.failure('network_error');
    }
  }

  @visibleForTesting
  static OsmPlace? parseOverpassElement(
    Map<String, dynamic> element,
    Set<OsmPlaceKind> kinds,
  ) {
    final tags = <String, String>{};
    final rawTags = element['tags'];
    if (rawTags is Map) {
      rawTags.forEach((k, v) => tags['$k'] = '$v');
    }
    final name = tags['name']?.trim();
    // Unnamed places are skipped rather than shown as "Unnamed hospital".
    if (name == null || name.isEmpty) return null;

    final kind = kindFromTags(tags);
    if (kind == null || !kinds.contains(kind)) return null;

    var lat = (element['lat'] as num?)?.toDouble();
    var lng = (element['lon'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      final center = element['center'];
      if (center is Map) {
        lat = (center['lat'] as num?)?.toDouble();
        lng = (center['lon'] as num?)?.toDouble();
      }
    }
    if (lat == null || lng == null) return null;

    return OsmPlace(
      id: '${element['type'] ?? 'node'}/${element['id']}',
      kind: kind,
      name: name,
      nameEn: tags['name:en'],
      nameAr: tags['name:ar'],
      latitude: lat,
      longitude: lng,
      address: _addressFromTags(tags),
      phone: tags['phone'] ?? tags['contact:phone'],
      website: tags['website'] ?? tags['contact:website'],
      emergencyTag: tags['emergency'],
      openingHours: tags['opening_hours'],
    );
  }

  static OsmPlaceKind? kindFromTags(Map<String, String> tags) {
    final amenity = tags['amenity'];
    final healthcare = tags['healthcare'];
    if (amenity == 'hospital' || healthcare == 'hospital') {
      return OsmPlaceKind.hospital;
    }
    if (amenity == 'clinic' || healthcare == 'clinic') {
      return OsmPlaceKind.clinic;
    }
    if (amenity == 'police') return OsmPlaceKind.police;
    if (amenity == 'fire_station') return OsmPlaceKind.fireStation;
    if (amenity == 'pharmacy' || healthcare == 'pharmacy') {
      return OsmPlaceKind.pharmacy;
    }
    return null;
  }

  static String? _addressFromTags(Map<String, String> tags) {
    final full = tags['addr:full'];
    if (full != null && full.isNotEmpty) return full;
    final street = tags['addr:street'];
    final parts = <String>[
      if (street != null)
        [tags['addr:housenumber'], street].whereType<String>().join(' '),
      ?tags['addr:city'],
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  // ------------------------------------------------------------- Nominatim

  static const _nominatimTypes = {
    OsmPlaceKind.hospital: 'hospital',
    OsmPlaceKind.clinic: 'clinic',
    OsmPlaceKind.police: 'police',
    OsmPlaceKind.fireStation: 'fire_station',
    OsmPlaceKind.pharmacy: 'pharmacy',
  };

  Future<OsmFetchResult> _nominatim(
    double lat,
    double lng,
    int radius,
    Set<OsmPlaceKind> kinds,
  ) async {
    final box = boundingBox(lat, lng, radius);
    final places = <OsmPlace>[];
    var anySuccess = false;
    var error = 'network_error';
    var first = true;
    for (final kind in kinds) {
      // Nominatim's usage policy: at most one request per second.
      if (!first) {
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      }
      first = false;
      final uri = Uri.parse(nominatimEndpoint).replace(
        queryParameters: {
          'amenity': _nominatimTypes[kind]!,
          'format': 'jsonv2',
          'limit': '40',
          'bounded': '1',
          'viewbox': box,
          'extratags': '1',
          'namedetails': '1',
          'addressdetails': '1',
        },
      );
      try {
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) {
          error = 'server_error';
          continue;
        }
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is! List) {
          error = 'server_error';
          continue;
        }
        anySuccess = true;
        for (final raw in body) {
          if (raw is! Map) continue;
          final place = parseNominatimItem(
            Map<String, dynamic>.from(raw),
            kind,
          );
          if (place != null) places.add(place);
        }
      } on TimeoutException {
        error = 'timeout';
      } catch (e) {
        debugPrint('[OSM] nominatim failed: $e');
      }
    }
    if (!anySuccess) return OsmFetchResult.failure(error);
    return _finish(places, lat, lng, radius, 'nominatim');
  }

  @visibleForTesting
  static OsmPlace? parseNominatimItem(
    Map<String, dynamic> item,
    OsmPlaceKind kind,
  ) {
    final names = <String, String>{};
    final rawNames = item['namedetails'];
    if (rawNames is Map) rawNames.forEach((k, v) => names['$k'] = '$v');
    final name = ((item['name'] as String?) ?? names['name'])?.trim();
    if (name == null || name.isEmpty) return null;

    final lat = double.tryParse('${item['lat']}');
    final lng = double.tryParse('${item['lon']}');
    if (lat == null || lng == null) return null;

    final extra = <String, String>{};
    final rawExtra = item['extratags'];
    if (rawExtra is Map) rawExtra.forEach((k, v) => extra['$k'] = '$v');

    String? address;
    final addr = item['address'];
    if (addr is Map) {
      final road = addr['road'] as String?;
      final house = addr['house_number'] as String?;
      final area =
          (addr['suburb'] ?? addr['neighbourhood'] ?? addr['quarter'])
              as String?;
      final city = (addr['city'] ?? addr['town'] ?? addr['village']) as String?;
      final parts = <String>[
        if (road != null) [house, road].whereType<String>().join(' '),
        ?area,
        ?city,
      ];
      if (parts.isNotEmpty) address = parts.join(', ');
    }

    return OsmPlace(
      id: '${item['osm_type'] ?? 'node'}/${item['osm_id']}',
      kind: kind,
      name: name,
      nameEn: names['name:en'],
      nameAr: names['name:ar'],
      latitude: lat,
      longitude: lng,
      address: address,
      phone: extra['phone'] ?? extra['contact:phone'],
      website: extra['website'] ?? extra['contact:website'],
      emergencyTag: extra['emergency'],
      openingHours: extra['opening_hours'],
    );
  }

  /// `left,top,right,bottom` box roughly [radius] metres around a point.
  static String boundingBox(double lat, double lng, int radius) {
    final dLat = radius / 111320.0;
    final cosLat = math.max(math.cos(lat * math.pi / 180), 0.0175);
    final dLng = radius / (111320.0 * cosLat);
    String f(double v) => v.toStringAsFixed(5);
    return '${f(lng - dLng)},${f(lat + dLat)},${f(lng + dLng)},${f(lat - dLat)}';
  }

  // ---------------------------------------------------------------- common

  /// Keeps places inside the radius, removes duplicates (same OSM id, or
  /// the same name within 150 m - e.g. a hospital tagged as both a node
  /// and a building outline).
  OsmFetchResult _finish(
    List<OsmPlace> raw,
    double lat,
    double lng,
    int radius,
    String source,
  ) {
    final result = dedupe(raw, lat, lng, radius);
    if (result.isEmpty) return const OsmFetchResult.failure('no_results');
    debugPrint('[OSM] $source: ${result.length} places');
    return OsmFetchResult.success(result, source);
  }

  @visibleForTesting
  static List<OsmPlace> dedupe(
    List<OsmPlace> raw,
    double lat,
    double lng,
    int radius,
  ) {
    final seenIds = <String>{};
    final kept = <OsmPlace>[];
    for (final p in raw) {
      if (!seenIds.add(p.id)) continue;
      if (haversineKm(lat, lng, p.latitude, p.longitude) * 1000 >
          radius * 1.05) {
        continue;
      }
      final duplicate = kept.any(
        (k) =>
            k.kind == p.kind &&
            k.name == p.name &&
            haversineKm(k.latitude, k.longitude, p.latitude, p.longitude) <
                0.15,
      );
      if (!duplicate) kept.add(p);
    }
    return kept;
  }
}
