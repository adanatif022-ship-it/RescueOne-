import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? errorKey;

  const LocationResult.success(this.latitude, this.longitude) : errorKey = null;

  const LocationResult.failure(this.errorKey)
    : latitude = null,
      longitude = null;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Wraps geolocator with safe fallbacks - never throws, always returns a
/// result the UI can render (attached / failed) without crashing.
class LocationService {
  /// Every await below carries its own timeout in addition to the
  /// [LocationSettings.timeLimit] passed to the plugin, because Chrome's
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

      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          ).timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw TimeoutException('location fix timed out'),
          );
      return LocationResult.success(position.latitude, position.longitude);
    } on TimeoutException {
      return const LocationResult.failure('timeout');
    } catch (_) {
      return const LocationResult.failure('unknown_error');
    }
  }

  double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
