import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;

  /// Radius in metres within which the real position lies (68% confidence),
  /// as reported by the device. Null when unknown.
  final double? accuracyMeters;

  /// True when the user only allowed *approximate* location (Android 12+,
  /// iOS 14+): the position can be off by several kilometres.
  final bool approximateOnly;

  final String? errorKey;

  const LocationResult.success(
    this.latitude,
    this.longitude, {
    this.accuracyMeters,
    this.approximateOnly = false,
  }) : errorKey = null;

  const LocationResult.failure(this.errorKey)
    : latitude = null,
      longitude = null,
      accuracyMeters = null,
      approximateOnly = false;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Wraps geolocator with safe fallbacks - never throws, always returns a
/// result the UI can render (attached / failed) without crashing.
///
/// Accuracy: the first position a phone reports is often a rough network
/// estimate given before GPS has locked on. So instead of taking that first
/// reading, positions are watched for up to [fixWindow] and the most
/// accurate one wins; it stops early once one is within [goodAccuracy].
class LocationService {
  LocationService({
    this.fixWindow = const Duration(seconds: 10),
    this.goodAccuracyMeters = 50,
  });

  final Duration fixWindow;
  final double goodAccuracyMeters;

  /// Highest-accuracy settings for each platform.
  static LocationSettings get _settings {
    if (kIsWeb) {
      // maximumAge zero = never reuse a cached browser position.
      return WebSettings(
        accuracy: LocationAccuracy.best,
        maximumAge: Duration.zero,
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1),
        );
      case TargetPlatform.iOS:
        return AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          // Foreground only: the app doesn't declare background location.
          allowBackgroundLocationUpdates: false,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        );
    }
  }

  /// Every await below carries its own timeout, because Chrome's
  /// geolocation bridge (and some browsers/devices) can leave the
  /// underlying platform call pending indefinitely instead of rejecting -
  /// this guarantees the method always resolves instead of hanging the
  /// caller's loading state forever.
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      if (!serviceEnabled) {
        return const LocationResult.failure('service_disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => LocationPermission.denied,
          );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 15),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          return const LocationResult.failure('permission_denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure('permission_denied_forever');
      }

      final position = await _bestPosition();
      if (position == null) return const LocationResult.failure('timeout');
      return LocationResult.success(
        position.latitude,
        position.longitude,
        accuracyMeters: position.accuracy > 0 ? position.accuracy : null,
        approximateOnly: await _isApproximateOnly(),
      );
    } on TimeoutException {
      return const LocationResult.failure('timeout');
    } catch (_) {
      return const LocationResult.failure('unknown_error');
    }
  }

  /// Watches positions for up to [fixWindow] and keeps the most accurate.
  Future<Position?> _bestPosition() async {
    Position? best;
    final done = Completer<void>();
    StreamSubscription<Position>? sub;
    try {
      sub = Geolocator.getPositionStream(locationSettings: _settings).listen(
        (p) {
          if (best == null || p.accuracy < best!.accuracy) best = p;
          if (p.accuracy > 0 &&
              p.accuracy <= goodAccuracyMeters &&
              !done.isCompleted) {
            done.complete();
          }
        },
        onError: (Object _) {
          if (!done.isCompleted) done.complete();
        },
        cancelOnError: true,
      );
      await done.future.timeout(fixWindow, onTimeout: () {});
    } catch (_) {
      // Fall through to a single reading below.
    } finally {
      await sub?.cancel();
    }
    if (best != null) return best;

    // Some platforms don't stream; ask once.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      ).timeout(const Duration(seconds: 12));
    } catch (_) {
      return null;
    }
  }

  /// True when only approximate location was allowed (phones only).
  Future<bool> _isApproximateOnly() async {
    if (kIsWeb) return false;
    try {
      final status = await Geolocator.getLocationAccuracy().timeout(
        const Duration(seconds: 3),
      );
      return status == LocationAccuracyStatus.reduced;
    } catch (_) {
      return false;
    }
  }

  /// Opens this app's settings page so the user can allow precise location.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
