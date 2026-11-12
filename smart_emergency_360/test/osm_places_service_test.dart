import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_emergency_360/core/models/osm_place.dart';
import 'package:smart_emergency_360/core/services/osm_places_service.dart';

const _aden = (lat: 12.7855, lng: 45.0187);

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('builds a query for the requested kinds only', () {
    final q = OsmPlacesService.buildOverpassQuery(1, 2, 10000, {
      OsmPlaceKind.hospital,
      OsmPlaceKind.pharmacy,
    });
    expect(q, contains('nwr["amenity"="hospital"](around:10000,1.0,2.0);'));
    expect(q, contains('["healthcare"="pharmacy"]'));
    expect(q, isNot(contains('police')));
    expect(q, endsWith('out center tags;'));
  });

  test('parses Overpass elements and skips unnamed places', () {
    final kinds = {OsmPlaceKind.hospital, OsmPlaceKind.clinic};
    final way = OsmPlacesService.parseOverpassElement({
      'type': 'way',
      'id': 173088502,
      'center': {'lat': 12.8057, 'lon': 45.0380},
      'tags': {
        'healthcare': 'hospital',
        'name': 'مستشفى الجمهورية',
        'name:en': 'Al-Jumhuriya Hospital',
        'emergency': 'yes',
        'phone': '+967 2 123456',
      },
    }, kinds)!;
    expect(way.id, 'way/173088502');
    expect(way.kind, OsmPlaceKind.hospital);
    expect(way.nameEn, 'Al-Jumhuriya Hospital');
    expect(way.emergencyTag, 'yes');
    expect(way.latitude, 12.8057);

    expect(
      OsmPlacesService.parseOverpassElement({
        'type': 'node',
        'id': 1,
        'lat': 1.0,
        'lon': 1.0,
        'tags': {'amenity': 'hospital'},
      }, kinds),
      isNull,
    );
    // A pharmacy is ignored when only hospitals/clinics were requested.
    expect(
      OsmPlacesService.parseOverpassElement({
        'type': 'node',
        'id': 2,
        'lat': 1.0,
        'lon': 1.0,
        'tags': {'amenity': 'pharmacy', 'name': 'X'},
      }, kinds),
      isNull,
    );
  });

  test('removes duplicates and places outside the radius', () {
    final a = OsmPlace(
      id: 'node/1',
      kind: OsmPlaceKind.hospital,
      name: 'A',
      latitude: _aden.lat,
      longitude: _aden.lng,
    );
    final sameBuilding = OsmPlace(
      id: 'way/9',
      kind: OsmPlaceKind.hospital,
      name: 'A',
      latitude: _aden.lat + 0.0005,
      longitude: _aden.lng,
    );
    final far = OsmPlace(
      id: 'node/2',
      kind: OsmPlaceKind.hospital,
      name: 'Far',
      latitude: _aden.lat + 0.5,
      longitude: _aden.lng,
    );
    final result = OsmPlacesService.dedupe(
      [a, a, sameBuilding, far],
      _aden.lat,
      _aden.lng,
      10000,
    );
    expect(result.map((p) => p.id), ['node/1']);
  });

  test('falls back to Nominatim when every Overpass server fails', () async {
    final requested = <String>[];
    final client = MockClient((request) async {
      requested.add(request.url.host);
      if (request.url.host == 'nominatim.openstreetmap.org') {
        final type = request.url.queryParameters['amenity'];
        return _json([
          {
            'osm_type': 'node',
            'osm_id': type == 'hospital' ? 11 : 22,
            'lat': '12.79',
            'lon': '45.02',
            'name': type == 'hospital' ? 'مستشفى عدن' : 'عيادة',
            'namedetails': {'name:en': 'Aden Hospital'},
            'extratags': {'emergency': 'yes'},
          },
        ]);
      }
      return http.Response('Not Acceptable', 406);
    });
    final service = OsmPlacesService(
      client: client,
      stagger: const Duration(milliseconds: 10),
    );

    final result = await service.fetch(
      lat: _aden.lat,
      lng: _aden.lng,
      kinds: {OsmPlaceKind.hospital, OsmPlaceKind.clinic},
    );

    expect(result.isSuccess, isTrue);
    expect(result.source, 'nominatim');
    expect(result.places.map((p) => p.kind), [
      OsmPlaceKind.hospital,
      OsmPlaceKind.clinic,
    ]);
    expect(result.places.first.nameEn, 'Aden Hospital');
    expect(requested, contains('overpass-api.de'));
  });

  test('first successful Overpass answer wins', () async {
    final client = MockClient((request) async {
      if (request.url.host == 'overpass-api.de') {
        return _json({
          'elements': [
            {
              'type': 'node',
              'id': 5,
              'lat': 12.79,
              'lon': 45.02,
              'tags': {'amenity': 'hospital', 'name': 'H'},
            },
          ],
        });
      }
      return http.Response('busy', 504);
    });
    final result = await OsmPlacesService(
      client: client,
    ).fetch(lat: _aden.lat, lng: _aden.lng, kinds: {OsmPlaceKind.hospital});
    expect(result.isSuccess, isTrue);
    expect(result.source, 'overpass-api.de');
    expect(result.places.single.id, 'node/5');
  });

  test('reports a clear error when every source fails', () async {
    final client = MockClient((_) async => http.Response('down', 502));
    final result = await OsmPlacesService(
      client: client,
      stagger: const Duration(milliseconds: 10),
    ).fetch(lat: 1, lng: 1, kinds: {OsmPlaceKind.hospital});
    expect(result.isSuccess, isFalse);
    expect(result.errorKey, 'server_error');
  });
}
