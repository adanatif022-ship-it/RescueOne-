import 'dart:math';
import '../config/app_config.dart';
import '../models/hospital.dart';
import '../models/osm_place.dart';

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

/// Estimated driving time for a real distance (4 minutes minimum).
int travelMinutesFor(double distanceKm) =>
    ((distanceKm / AppConfig.averageSpeedKmh) * 60).round().clamp(4, 999);

int _stableHash(String id, int salt) {
  var hash = salt;
  for (final unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

/// Simulated congestion/wait-time pair for a hospital identified by [id],
/// varied by hour-of-day/weekday so it looks like it changes over time.
/// There is no public live feed for ER congestion, so this stays an
/// estimate for every real hospital returned (see hospitals_disclaimer).
({CongestionLevel congestion, int waitMinutes}) simulateOperationalMetrics(
  String id,
  DateTime now,
) {
  final hourBucket = now.hour ~/ 4; // 6 buckets across the day
  final busyness = _stableHash(id, hourBucket * 17 + now.weekday) % 100;
  if (busyness < 35) {
    return (congestion: CongestionLevel.low, waitMinutes: 10 + (busyness % 15));
  } else if (busyness < 70) {
    return (
      congestion: CongestionLevel.moderate,
      waitMinutes: 30 + (busyness % 20),
    );
  } else {
    return (
      congestion: CongestionLevel.high,
      waitMinutes: 55 + (busyness % 35),
    );
  }
}

/// Turns a real OSM hospital/clinic into the app's [Hospital], measuring
/// the real distance from the user and adding the labeled estimates.
Hospital hospitalFromPlace(
  OsmPlace place,
  double userLat,
  double userLng,
  DateTime now,
) {
  final distanceKm = haversineKm(
    userLat,
    userLng,
    place.latitude,
    place.longitude,
  );
  final metrics = simulateOperationalMetrics(place.id, now);
  return Hospital(
    id: place.id,
    nameEn: place.nameEn ?? place.name,
    nameAr: place.nameAr ?? place.name,
    latitude: place.latitude,
    longitude: place.longitude,
    distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
    travelTimeMinutes: travelMinutesFor(distanceKm),
    congestion: metrics.congestion,
    estimatedWaitMinutes: metrics.waitMinutes,
    category: place.kind == OsmPlaceKind.clinic
        ? HospitalCategory.clinic
        : HospitalCategory.hospital,
    address: place.address,
    phone: place.phone,
    website: place.website,
    hasEmergencyDepartment: switch (place.emergencyTag) {
      'yes' => true,
      'no' => false,
      _ => null,
    },
    openingHoursText: place.openingHours,
  );
}
