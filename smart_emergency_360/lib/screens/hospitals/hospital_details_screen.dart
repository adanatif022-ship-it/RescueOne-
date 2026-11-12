import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/hospital.dart';
import '../../core/services/launcher_service.dart';
import '../../core/services/saved_places_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/responsive_section.dart';

/// Full-page view of a single hospital, reached from the Hospitals list,
/// the Home recommended-hospital card, and incident details. Reuses the
/// exact same [Hospital] object the list/recommendation already computed
/// - no separate hard-coded data for this screen. Every field shown here
/// is either real OpenStreetMap data (name, address, coordinates,
/// distance, phone, website, emergency-department tag, opening hours) or
/// a clearly-labeled simulated estimate (wait time, congestion).
class HospitalDetailsScreen extends StatelessWidget {
  final Hospital hospital;
  final bool isRecommended;

  const HospitalDetailsScreen({
    super.key,
    required this.hospital,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.lang.isArabic;
    final name = isArabic ? hospital.nameAr : hospital.nameEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('hospitals_details_title')),
        actions: [_SavePlaceButton(hospital: hospital, name: name)],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: AppColors.primaryBlue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (hospital.address != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hospital.address!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  label: Text(
                                    context.tr(
                                      hospitalCategoryKey(hospital.category),
                                    ),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: AppColors.subtleFill,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                if (isRecommended)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      context.tr('hospitals_recommended_badge'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DisclaimerBanner(textKey: 'hospitals_disclaimer'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.tr('hospitals_osm_attribution'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 14,
                        children: [
                          _DetailMetric(
                            icon: Icons.route_rounded,
                            label: context.tr('maps_distance'),
                            value:
                                '${hospital.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')}',
                          ),
                          _DetailMetric(
                            icon: Icons.directions_car_filled_rounded,
                            label: context.tr('hospitals_travel_time'),
                            value:
                                '${hospital.travelTimeMinutes} ${context.tr('hospitals_min_short')}',
                          ),
                          _DetailMetric(
                            icon: Icons.timer_outlined,
                            label: context.tr('hospitals_wait_time'),
                            value:
                                '${hospital.estimatedWaitMinutes} ${context.tr('hospitals_min_short')}',
                            estimated: true,
                          ),
                          _DetailMetric(
                            icon: Icons.speed_rounded,
                            label: context.tr('hospitals_congestion'),
                            value: context.tr(
                              congestionKey(hospital.congestion),
                            ),
                            valueColor: congestionColor(hospital.congestion),
                            estimated: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              switch (hospital.hasEmergencyDepartment) {
                                true => Icons.check_circle_rounded,
                                false => Icons.cancel_rounded,
                                null => Icons.help_outline_rounded,
                              },
                              color: hospital.hasEmergencyDepartment == true
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr(
                                  switch (hospital.hasEmergencyDepartment) {
                                    true => 'hospitals_emergency_yes',
                                    false => 'hospitals_emergency_no',
                                    null => 'hospitals_emergency_unknown',
                                  },
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hospital.openingHoursText != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('hospitals_hours'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    hospital.openingHoursText!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hospital.phone != null) ...[
                    const SizedBox(height: 16),
                    _ContactRow(
                      icon: Icons.phone_rounded,
                      label: context.tr('hospitals_phone'),
                      value: hospital.phone!,
                      onTap: () =>
                          LauncherService().callNumber(hospital.phone!),
                    ),
                  ],
                  if (hospital.website != null) ...[
                    const SizedBox(height: 12),
                    _ContactRow(
                      icon: Icons.language_rounded,
                      label: context.tr('hospitals_website'),
                      value: hospital.website!,
                      onTap: () => LauncherService().openUrl(
                        hospital.website!.startsWith('http')
                            ? hospital.website!
                            : 'https://${hospital.website!}',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GradientButton(
                    label: context.tr('hospitals_open_maps'),
                    icon: Icons.map_rounded,
                    onPressed: () async {
                      final ok = await LauncherService().openMapsDirections(
                        destinationLat: hospital.latitude,
                        destinationLng: hospital.longitude,
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.trRead('maps_open_failed')),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    LtrText(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool estimated;

  const _DetailMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.estimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          if (estimated)
            Text(
              context.tr('estimated_prototype_value'),
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bookmark button: saves this hospital to "Saved places".
class _SavePlaceButton extends StatelessWidget {
  final Hospital hospital;
  final String name;
  const _SavePlaceButton({required this.hospital, required this.name});

  @override
  Widget build(BuildContext context) {
    final places = context.watch<SavedPlacesRepository>();
    final saved = places.isSaved(hospital.latitude, hospital.longitude);
    return IconButton(
      tooltip: context.tr('hospitals_save_place'),
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
        color: AppColors.primaryBlue,
      ),
      onPressed: () async {
        if (saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.trRead('hospitals_already_saved'))),
          );
          return;
        }
        await places.add(
          name: name,
          latitude: hospital.latitude,
          longitude: hospital.longitude,
          note: hospital.address,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.trRead('hospitals_place_saved'))),
          );
        }
      },
    );
  }
}
