import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/models/hospital.dart';
import '../../core/models/incident.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/section_title.dart';
import 'hospital_details_screen.dart';

/// Real nearby hospitals/clinics from OpenStreetMap with the Smart Hospital
/// Routing recommendation (see hospital_ranking.dart). The recommendation
/// can be viewed for any incident type. Congestion and waiting time are
/// labeled estimates. Nothing is invented when data is missing: the screen
/// explains what failed and offers a retry, and shows the last saved list
/// (with its date) when offline.
class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  IncidentType _type = IncidentType.medical;

  @override
  void initState() {
    super.initState();
    // With "location only when needed", nothing has been loaded yet -
    // opening this screen is the moment it's needed.
    final repo = context.read<HospitalRepository>();
    if (!repo.hasStarted || (repo.hospitals.isEmpty && !repo.isLoading)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => repo.refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HospitalRepository>();
    final hospitals = repo.hospitals;
    final recommended = repo.recommendationFor(_type);
    final isInitialLoad = repo.isLoading && hospitals.isEmpty;
    final isArabic = context.lang.isArabic;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(context.tr('hospitals_title')),
      ),
      body: isInitialLoad
          ? _LoadingView(loadingText: context.tr('hospitals_loading'))
          : RefreshIndicator(
              onRefresh: () => repo.refresh(force: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
                children: [
                  Text(
                    context.tr('hospitals_subtitle'),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const DisclaimerBanner(textKey: 'hospitals_disclaimer'),
                  if (repo.isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  if (repo.locationErrorKey != null) ...[
                    const SizedBox(height: 12),
                    _LocationErrorBanner(
                      errorKey: repo.locationErrorKey!,
                      loading: repo.isLoading,
                      onRetry: () => repo.refresh(force: true),
                    ),
                  ],
                  if (repo.overpassErrorKey != null) ...[
                    const SizedBox(height: 12),
                    _DataErrorBanner(
                      errorKey: repo.overpassErrorKey!,
                      loading: repo.isLoading,
                      onRetry: () => repo.refresh(force: true),
                    ),
                  ],
                  if (repo.usingSavedData && repo.dataFetchedAt != null) ...[
                    const SizedBox(height: 12),
                    _SavedDataBanner(
                      time: DateFormat(
                        'd MMM, HH:mm',
                        isArabic ? 'ar' : 'en',
                      ).format(repo.dataFetchedAt!),
                    ),
                  ],
                  if (hospitals.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const _OsmAttribution(),
                    const SizedBox(height: 16),
                    _TypeSelector(
                      selected: _type,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (hospitals.isEmpty && !repo.isLoading)
                    _EmptyState(onFind: () => repo.refresh(force: true)),
                  if (recommended != null) ...[
                    SectionTitle(
                      title: context.tr('hospitals_recommended_badge'),
                    ),
                    _HospitalCard(
                      hospital: recommended,
                      isRecommended: true,
                      reasonKeys: repo.recommendationReasonKeys(
                        recommended,
                        _type,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionTitle(title: context.tr('hospitals_compare')),
                  ],
                  ...hospitals
                      .where((h) => h.id != recommended?.id)
                      .map(
                        (hospital) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HospitalCard(
                            hospital: hospital,
                            isRecommended: false,
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}

/// "Recommend for: Medical / Fire / ..." - the ranking changes with the
/// incident type (e.g. clinics are penalised for critical cases).
class _TypeSelector extends StatelessWidget {
  final IncidentType selected;
  final ValueChanged<IncidentType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('hospitals_recommend_for'),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: IncidentType.values.map((type) {
              final isSelected = type == selected;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  avatar: Icon(
                    incidentTypeIcon(type),
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                  ),
                  label: Text(context.tr(incidentTypeKey(type))),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(type),
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onFind;
  const _EmptyState({required this.onFind});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_hospital_outlined,
              size: 36,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('hospitals_empty'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onFind,
            style: OutlinedButton.styleFrom(minimumSize: const Size(220, 48)),
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: Text(context.tr('home_find_hospitals')),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String loadingText;
  const _LoadingView({required this.loadingText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(loadingText, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LocationErrorBanner extends StatelessWidget {
  final String errorKey;
  final bool loading;
  final VoidCallback onRetry;

  const _LocationErrorBanner({
    required this.errorKey,
    required this.loading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_off_rounded,
                color: AppColors.dangerRed,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr(locationErrorKey(errorKey)),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  icon: const Icon(Icons.my_location_rounded, size: 16),
                  label: Text(context.tr('hospitals_request_permission')),
                ),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(context.tr('hospitals_retry')),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DataErrorBanner extends StatelessWidget {
  final String errorKey;
  final bool loading;
  final VoidCallback onRetry;

  const _DataErrorBanner({
    required this.errorKey,
    required this.loading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(overpassErrorKey(errorKey)),
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: onRetry,
                  child: Text(context.tr('hospitals_retry')),
                ),
        ],
      ),
    );
  }
}

class _SavedDataBanner extends StatelessWidget {
  final String time;
  const _SavedDataBanner({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.trArgs('hospitals_saved_data', {'time': time}),
              style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.public_rounded, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.tr('hospitals_osm_attribution'),
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final bool isRecommended;
  final List<String>? reasonKeys;

  const _HospitalCard({
    required this.hospital,
    required this.isRecommended,
    this.reasonKeys,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HospitalDetailsScreen(
            hospital: hospital,
            isRecommended: isRecommended,
          ),
        ),
      ),
      child: PremiumCard(
        highlighted: isRecommended,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hospital.isClinic
                        ? Icons.medical_services_rounded
                        : Icons.local_hospital_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hospital.nameFor(arabic: lang.isArabic),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
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
            if (hospital.address != null) ...[
              const SizedBox(height: 6),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Metric(
                  icon: Icons.route_rounded,
                  label: context.tr('maps_distance'),
                  value:
                      '${hospital.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')}',
                ),
                _Metric(
                  icon: Icons.directions_car_filled_rounded,
                  label: context.tr('hospitals_travel_time'),
                  value:
                      '${hospital.travelTimeMinutes} ${context.tr('hospitals_min_short')}',
                ),
                _Metric(
                  icon: Icons.timer_outlined,
                  label: context.tr('hospitals_wait_time'),
                  value:
                      '${hospital.estimatedWaitMinutes} ${context.tr('hospitals_min_short')}',
                  estimated: true,
                ),
                _Metric(
                  icon: Icons.speed_rounded,
                  label: context.tr('hospitals_congestion'),
                  value: context.tr(congestionKey(hospital.congestion)),
                  valueColor: congestionColor(hospital.congestion),
                  estimated: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Tag(label: context.tr(hospitalCategoryKey(hospital.category))),
                if (hospital.hasEmergencyDepartment == true)
                  _Tag(
                    icon: Icons.emergency_rounded,
                    label: context.tr('hospitals_emergency_yes'),
                    color: AppColors.success,
                  ),
              ],
            ),
            if (reasonKeys != null && reasonKeys!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${context.tr('hospitals_reason_prefix')} '
                  '${lang.joinList(reasonKeys!.map(context.tr))}.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                    SnackBar(content: Text(context.trRead('maps_open_failed'))),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  const _Tag({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color == null ? AppColors.subtleFill : c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool estimated;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.estimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
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
    );
  }
}
