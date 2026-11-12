import 'package:flutter_test/flutter_test.dart';
import 'package:smart_emergency_360/core/models/hospital.dart';
import 'package:smart_emergency_360/core/models/incident.dart';
import 'package:smart_emergency_360/core/services/hospital_ranking.dart';

import 'test_helpers.dart';

void main() {
  test('a much shorter wait beats a slightly closer hospital', () {
    final near = hospital('near', distanceKm: 1.1, travel: 4, wait: 85);
    final fast = hospital('fast', distanceKm: 1.8, travel: 4, wait: 15);
    expect(recommendHospital([near, fast], IncidentType.medical)!.id, 'fast');
  });

  test('critical cases prefer a hospital over a closer clinic', () {
    final clinic = hospital(
      'clinic',
      distanceKm: 0.5,
      travel: 4,
      wait: 20,
      category: HospitalCategory.clinic,
    );
    final full = hospital('full', distanceKm: 2.0, travel: 4, wait: 30);
    expect(recommendHospital([clinic, full], IncidentType.medical)!.id, 'full');
    expect(
      recommendHospital([clinic, full], IncidentType.accident)!.id,
      'full',
    );
    // For a non-critical case the clinic's shorter wait can win.
    expect(recommendHospital([clinic, full], IncidentType.other)!.id, 'clinic');
  });

  test('a tagged emergency department is preferred for critical cases', () {
    final noTag = hospital('a', travel: 5, wait: 30);
    final er = hospital('b', travel: 7, wait: 30, er: true);
    expect(recommendHospital([noTag, er], IncidentType.medical)!.id, 'b');
  });

  test('empty list gives no recommendation', () {
    expect(recommendHospital([], IncidentType.medical), isNull);
  });

  test('reasons explain the choice', () {
    final clinic = hospital(
      'clinic',
      distanceKm: 0.5,
      wait: 50,
      category: HospitalCategory.clinic,
    );
    final full = hospital(
      'full',
      distanceKm: 2.0,
      wait: 20,
      er: true,
      congestion: CongestionLevel.low,
    );
    final reasons = recommendationReasonKeys(full, [
      clinic,
      full,
    ], IncidentType.medical);
    expect(reasons, contains('hospitals_reason_fastest'));
    expect(reasons, contains('hospitals_reason_er'));
    expect(reasons, contains('hospitals_reason_full_hospital'));
    expect(reasons, contains('hospitals_reason_congestion'));
    expect(reasons, isNot(contains('hospitals_reason_nearest')));

    expect(recommendationReasonKeys(full, [full], IncidentType.medical), [
      'hospitals_reason_only',
    ]);
  });
}
