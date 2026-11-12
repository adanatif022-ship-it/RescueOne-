import '../models/hospital.dart';
import '../models/incident.dart';

/// Smart Hospital Routing - pure functions so they can be unit tested.
///
/// The old version always recommended the *nearest* facility. This one
/// scores every real facility by the estimated time until the patient is
/// seen, adjusted for the incident type:
///
///   score = travel minutes + 0.6 x estimated wait minutes
///           + clinic penalty   (a clinic is a poor choice for a critical case)
///           +/- emergency-department adjustment (from the real OSM tag)
///
/// The wait estimate is weighted at 0.6 because it is a simulated value
/// (see hospitals_disclaimer) while the travel time comes from the real
/// distance. Lower score = better.
bool isCriticalType(IncidentType type) =>
    type == IncidentType.medical ||
    type == IncidentType.accident ||
    type == IncidentType.fire ||
    type == IncidentType.danger;

double hospitalScore(Hospital h, IncidentType type) {
  final critical = isCriticalType(type);
  var score = h.travelTimeMinutes + 0.6 * h.estimatedWaitMinutes;
  if (h.isClinic) score += critical ? 25 : 6;
  if (h.hasEmergencyDepartment == true) score -= critical ? 10 : 4;
  if (h.hasEmergencyDepartment == false) score += critical ? 30 : 8;
  return score;
}

/// Best facility for [type], or null when the list is empty. Ties go to
/// the closer facility.
Hospital? recommendHospital(List<Hospital> hospitals, IncidentType type) {
  if (hospitals.isEmpty) return null;
  Hospital best = hospitals.first;
  var bestScore = hospitalScore(best, type);
  for (final h in hospitals.skip(1)) {
    final s = hospitalScore(h, type);
    if (s < bestScore || (s == bestScore && h.distanceKm < best.distanceKm)) {
      best = h;
      bestScore = s;
    }
  }
  return best;
}

/// Translation keys explaining *why* [recommended] was chosen over the
/// other facilities - shown on the recommended card instead of just a
/// badge.
List<String> recommendationReasonKeys(
  Hospital recommended,
  List<Hospital> all,
  IncidentType type,
) {
  final others = all.where((h) => h.id != recommended.id).toList();
  if (others.isEmpty) return ['hospitals_reason_only'];

  final critical = isCriticalType(type);
  final reasons = <String>[];
  int total(Hospital h) => h.travelTimeMinutes + h.estimatedWaitMinutes;

  if (others.every((h) => h.distanceKm >= recommended.distanceKm)) {
    reasons.add('hospitals_reason_nearest');
  }
  if (others.every((h) => total(h) >= total(recommended))) {
    reasons.add('hospitals_reason_fastest');
  } else if (others.every(
    (h) => h.estimatedWaitMinutes >= recommended.estimatedWaitMinutes,
  )) {
    reasons.add('hospitals_reason_wait');
  }
  if (recommended.congestion != CongestionLevel.high &&
      others.every((h) => h.congestion.index >= recommended.congestion.index)) {
    reasons.add('hospitals_reason_congestion');
  }
  if (critical && recommended.hasEmergencyDepartment == true) {
    reasons.add('hospitals_reason_er');
  }
  if (critical &&
      !recommended.isClinic &&
      others.any((h) => h.isClinic && h.distanceKm < recommended.distanceKm)) {
    reasons.add('hospitals_reason_full_hospital');
  }
  if (reasons.isEmpty) reasons.add('hospitals_reason_balance');
  return reasons;
}
