import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/incident.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/incident_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/responsive_section.dart';
import '../../core/widgets/status_timeline.dart';
import '../root/root_shell.dart';
import 'assistance_completed_screen.dart';
import 'notify_contacts_sheet.dart';

/// Tracking screen after an incident is created: real location, the
/// recommended real hospital with directions, the (simulated) status
/// timeline, and the real actions - calling emergency services (always an
/// explicit, confirmed tap) and texting trusted contacts.
class IncidentProgressScreen extends StatelessWidget {
  final String incidentId;
  const IncidentProgressScreen({super.key, required this.incidentId});

  static Future<void> confirmEmergencyCall(BuildContext context) async {
    final number = context.read<SettingsRepository>().emergencyNumber;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('sos_call_confirm_title')),
        content: Text(
          dialogContext.trArgsRead('sos_call_confirm_body', {'number': number}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              minimumSize: const Size(120, 44),
            ),
            child: Text(dialogContext.tr('sos_call_emergency')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await LauncherService().callNumber(number);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.trRead('sos_call_failed'))),
        );
      }
    }
  }

  Future<void> _confirmCancel(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('sos_cancel_confirm_title')),
        content: Text(dialogContext.tr('sos_cancel_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('back')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              minimumSize: const Size(120, 44),
            ),
            child: Text(dialogContext.tr('sos_cancel_request')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<IncidentRepository>().cancelIncident(id);
      if (context.mounted) _goHome(context);
    }
  }

  Future<void> _markAssisted(BuildContext context, String id) async {
    await context.read<IncidentRepository>().updateStatus(
      id,
      IncidentStatus.assisted,
    );
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AssistanceCompletedScreen(incidentId: id),
        ),
        (route) => false,
      );
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = context.watch<IncidentRepository>().byId(incidentId);

    return PopScope(
      // "Back" always returns to Home with the full app around it, even
      // when the SOS was sent from the welcome screen.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          // Back always lands on Home (never back into the SOS form).
          leading: AppBackButton(onPressed: () => _goHome(context)),
          title: Text(context.tr('sos_created_title')),
        ),
        body: incident == null
            ? Center(child: Text(context.tr('history_empty')))
            : SafeArea(
                child: SingleChildScrollView(
                  child: ResponsiveSection(
                    vertical: 16,
                    child: _ProgressBody(
                      incident: incident,
                      onCall: () => confirmEmergencyCall(context),
                      onNotify: () =>
                          showNotifyContactsSheet(context, incident),
                      onCancel: () => _confirmCancel(context, incident.id),
                      onMarkAssisted: () => _markAssisted(context, incident.id),
                      onBack: () => _goHome(context),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final Incident incident;
  final VoidCallback onCall;
  final VoidCallback onNotify;
  final VoidCallback onCancel;
  final VoidCallback onMarkAssisted;
  final VoidCallback onBack;

  const _ProgressBody({
    required this.incident,
    required this.onCall,
    required this.onNotify,
    required this.onCancel,
    required this.onMarkAssisted,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = incident.status == IncidentStatus.cancelled;
    final canCancel = incident.status.isOpen;
    final canMarkAssisted = incident.status == IncidentStatus.helpOnWay;
    final emergencyNumber = context.watch<SettingsRepository>().emergencyNumber;

    // An alert created before hospital data arrived gets its
    // recommendation as soon as real data is available.
    if (incident.hospital == null && incident.status.isOpen) {
      final recommended = context.watch<HospitalRepository>().recommendationFor(
        incident.type,
      );
      if (recommended != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<IncidentRepository>().attachHospitalIfMissing(
            incident.id,
            recommended,
          ),
        );
      }
    }
    final hospital = incident.hospital;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCancelled
                ? AppColors.dangerRed.withValues(alpha: 0.1)
                : AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Row(
            children: [
              Icon(
                isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded,
                color: isCancelled ? AppColors.dangerRed : AppColors.success,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCancelled
                      ? context.tr('status_cancelled')
                      : context.tr('sos_created_message'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${context.tr('history_incident_number')} ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            LtrText(
              '#${incident.id}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // The real actions come first: in an emergency nobody should have
        // to scroll to find the call button.
        if (canMarkAssisted) ...[
          ElevatedButton.icon(
            onPressed: onMarkAssisted,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.task_alt_rounded),
            label: Text(context.tr('sos_mark_assisted')),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: onCall,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_rounded),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.tr('sos_call_emergency'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                context.trArgs('sos_dials_number', {'number': emergencyNumber}),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!isCancelled) ...[
          ElevatedButton.icon(
            onPressed: onNotify,
            icon: const Icon(Icons.sms_rounded),
            label: Text(context.tr('sos_notify_contacts')),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        _LocationCard(incident: incident),
        const SizedBox(height: 12),
        _HospitalCard(hospital: hospital),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricChip(
                icon: Icons.route_rounded,
                label: context.tr('maps_distance'),
                value: hospital != null
                    ? '${hospital.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')}'
                    : '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricChip(
                icon: Icons.timer_outlined,
                label: context.tr('sos_estimated_arrival'),
                value: hospital != null
                    ? '${hospital.travelTimeMinutes} ${context.tr('hospitals_min_short')}'
                    : '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricChip(
                icon: incidentTypeIcon(incident.type),
                label: context.tr('sos_responder_type'),
                value: context.tr(incidentTypeKey(incident.type)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!isCancelled)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('details_timeline'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatusTimeline(
                    currentStatus: incident.status,
                    times: incident.statusTimes,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        const DisclaimerBanner(textKey: 'sos_prototype_notice'),
        const SizedBox(height: 24),
        if (canCancel) ...[
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerRed,
              side: BorderSide(color: AppColors.dangerRed),
            ),
            child: Text(context.tr('sos_cancel_request')),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(onPressed: onBack, child: Text(context.tr('back'))),
      ],
    );
  }
}

/// The incident's real coordinates, openable in Google Maps.
class _LocationCard extends StatelessWidget {
  final Incident incident;
  const _LocationCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final location = incident.location;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            location != null
                ? Icons.my_location_rounded
                : Icons.location_off_rounded,
            color: location != null
                ? AppColors.primaryBlue
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('sos_your_location'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                location != null
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: LtrText(
                          '${location.latitude.toStringAsFixed(5)}, '
                          '${location.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Text(
                        context.tr('sos_location_not_attached'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ],
            ),
          ),
          if (location != null)
            IconButton.filledTonal(
              tooltip: context.tr('open_in_maps'),
              onPressed: () => LauncherService().openMapsForCoordinates(
                latitude: location.latitude,
                longitude: location.longitude,
              ),
              icon: const Icon(Icons.map_rounded),
            ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalSnapshot? hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final h = hospital;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: h == null
            ? Row(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('sos_no_hospital'),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('sos_recommended_hospital'),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              h.nameFor(arabic: context.lang.isArabic),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          onPressed: () => LauncherService().openMapsDirections(
                            destinationLat: h.latitude,
                            destinationLng: h.longitude,
                          ),
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          label: Text(context.tr('sos_route_to_hospital')),
                        ),
                      ),
                      if (h.phone != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              foregroundColor: AppColors.success,
                              side: const BorderSide(color: AppColors.success),
                            ),
                            onPressed: () =>
                                LauncherService().callNumber(h.phone!),
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: Text(context.tr('sos_call_hospital')),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
