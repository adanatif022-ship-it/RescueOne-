import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_emergency_360/core/services/location_service.dart';

Position _pos(double lat, double accuracy) => Position(
  latitude: lat,
  longitude: 45,
  timestamp: DateTime(2026),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

/// Device location that streams the given readings, one every [gap].
class _FakeGeolocator extends GeolocatorPlatform {
  _FakeGeolocator(
    this.readings, {
    this.gap = const Duration(milliseconds: 20),
    this.accuracyStatus = LocationAccuracyStatus.precise,
    this.streamFails = false,
  });

  final List<Position> readings;
  final Duration gap;
  final LocationAccuracyStatus accuracyStatus;
  final bool streamFails;
  bool streamCancelled = false;
  int singleReadings = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() async => accuracyStatus;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    late StreamController<Position> controller;
    Timer? timer;
    var i = 0;
    controller = StreamController<Position>(
      onListen: () {
        if (streamFails) {
          controller.addError(Exception('no stream'));
          return;
        }
        timer = Timer.periodic(gap, (_) {
          if (i < readings.length) controller.add(readings[i++]);
        });
      },
      onCancel: () {
        streamCancelled = true;
        timer?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    singleReadings++;
    return readings.first;
  }
}

void main() {
  test('keeps watching until a precise reading arrives, then stops', () async {
    final fake = _FakeGeolocator([
      _pos(1, 2500), // network estimate
      _pos(2, 400),
      _pos(3, 18), // GPS lock - good enough
      _pos(4, 5), // would arrive after the stream is stopped
    ], gap: const Duration(milliseconds: 30));
    GeolocatorPlatform.instance = fake;

    final watch = Stopwatch()..start();
    final result = await LocationService(
      fixWindow: const Duration(seconds: 5),
    ).getCurrentLocation();

    expect(result.hasLocation, isTrue);
    expect(result.latitude, 3);
    expect(result.accuracyMeters, 18);
    expect(fake.streamCancelled, isTrue);
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test(
    'without a precise reading, the most accurate one in the window wins',
    () async {
      GeolocatorPlatform.instance = _FakeGeolocator([
        _pos(1, 3000),
        _pos(2, 900),
        _pos(3, 1500),
      ]);
      final result = await LocationService(
        fixWindow: const Duration(milliseconds: 300),
      ).getCurrentLocation();

      expect(result.latitude, 2);
      expect(result.accuracyMeters, 900);
    },
  );

  test('reports when only approximate location is allowed', () async {
    GeolocatorPlatform.instance = _FakeGeolocator([
      _pos(1, 20),
    ], accuracyStatus: LocationAccuracyStatus.reduced);
    final result = await LocationService().getCurrentLocation();
    expect(result.approximateOnly, isTrue);
  });

  test('falls back to a single reading when streaming fails', () async {
    final fake = _FakeGeolocator([_pos(7, 30)], streamFails: true);
    GeolocatorPlatform.instance = fake;
    final result = await LocationService().getCurrentLocation();
    expect(result.latitude, 7);
    expect(fake.singleReadings, 1);
  });
}
