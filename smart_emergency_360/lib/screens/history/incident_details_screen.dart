import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/incident.dart';
import '../../core/services/incident_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/status_timeline.dart';
import '../sos/incident_progress_screen.dart';
import '../sos/notify_contacts_sheet.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailsScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final incident = context.watch<IncidentRepository>().byId(incidentId);
    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('details_title'))),
        body: Center(child: Text(context.tr('history_empty'))),
      );
    }

    final hospital = incident.hospital;
    final isArabic = context.lang.isArabic;
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', isArabic ? 'ar' : 'en');
    final isCancelled = incident.status == IncidentStatus.cancelled;
    final canAdvance = !isCancelled && incident.status != IncidentStatus.closed;
    final location = incident.location;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('details_title')),
        actions: [
          // Finished/cancelled incidents can be removed from the history;
          // an open one must be cancelled first.
          if (!incident.status.isOpen)
            IconButton(
              tooltip: context.tr('details_delete_incident'),
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, incident.id),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Icon(
                    incidentTypeIcon(incident.type),
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(incidentTypeKey(incident.type)),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        children: [
                          LtrText(
                            '#${incident.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            dateFormat.format(incident.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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
            if (isCancelled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: AppColors.dangerRed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('status_cancelled'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dangerRed,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatusTimeline(
                        currentStatus: incident.status,
                        times: incident.statusTimes,
                      ),
                      if (canAdvance)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () => context
                                .read<IncidentRepository>()
                                .advanceToNextStage(incident.id),
                            icon: const Icon(Icons.skip_next_rounded, size: 18),
                            label: Text(
                              context.tr(
                                incidentStatusKey(
                                  incidentStatusOrder[incident.status.step + 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (incident.status.isOpen) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () =>
                          IncidentProgressScreen.confirmEmergencyCall(context),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text(
                        context.tr('sos_call_emergency'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () =>
                          showNotifyContactsSheet(context, incident),
                      icon: const Icon(Icons.sms_rounded, size: 18),
                      label: Text(
                        context.tr('sos_notify_contacts'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _InfoRow(
                  label: context.tr('details_mode'),
                  value: Text(
                    incident.mode == AlertMode.silent
                        ? context.tr('sos_confirm_mode_silent')
                        : context.tr('sos_confirm_mode_normal'),
                    style: _valueStyle,
                  ),
                ),
                _InfoRow(
                  label: context.tr('details_location'),
                  value: location == null
                      ? Text(
                          context.tr('sos_confirm_location_no'),
                          style: _valueStyle,
                        )
                      : Row(
                          children: [
                            LtrText(
                              '${location.latitude.toStringAsFixed(5)}, '
                              '${location.longitude.toStringAsFixed(5)}',
                              style: _valueStyle,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () =>
                                  LauncherService().openMapsForCoordinates(
                                    latitude: location.latitude,
                                    longitude: location.longitude,
                                  ),
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: Text(context.tr('open_in_maps')),
                            ),
                          ],
                        ),
                ),
                _InfoRow(
                  label: context.tr('details_description'),
                  value: Text(
                    incident.description.isEmpty
                        ? context.tr('details_no_description')
                        : incident.description,
                    style: _valueStyle,
                  ),
                ),
              ],
            ),
            if (hospital != null) ...[
              const SizedBox(height: 16),
              _InfoCard(
                children: [
                  _InfoRow(
                    label: context.tr('details_recommended_hospital'),
                    value: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${hospital.nameFor(arabic: isArabic)} · '
                            '${hospital.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')}',
                            style: _valueStyle,
                          ),
                        ),
                        IconButton(
                          tooltip: context.tr('sos_route_to_hospital'),
                          onPressed: () => LauncherService().openMapsDirections(
                            destinationLat: hospital.latitude,
                            destinationLng: hospital.longitude,
                          ),
                          icon: Icon(
                            Icons.directions_rounded,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _InfoRow(
                  label: context.tr('details_responder'),
                  value: Text(
                    context.tr('details_responder_name'),
                    style: _valueStyle,
                  ),
                ),
                _InfoRow(
                  label: context.tr('details_final_status'),
                  value: Text(
                    context.tr(incidentStatusKey(incident.status)),
                    style: _valueStyle.copyWith(
                      color: incidentStatusColor(incident.status),
                    ),
                  ),
                ),
                if (incident.rating != null)
                  _InfoRow(
                    label: context.tr('details_rating'),
                    value: Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          Icon(
                            i <= incident.rating!
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.warning,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                if ((incident.feedback ?? '').isNotEmpty)
                  _InfoRow(
                    label: context.tr('details_feedback'),
                    value: Text(incident.feedback!, style: _valueStyle),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const DisclaimerBanner(textKey: 'sos_prototype_notice'),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
        title: Text(dialogContext.tr('details_delete_incident')),
        content: Text(dialogContext.tr('details_delete_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              minimumSize: const Size(100, 44),
            ),
            child: Text(dialogContext.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final repo = context.read<IncidentRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final doneText = context.trRead('details_deleted');
    Navigator.of(context).pop();
    await repo.deleteIncident(id);
    messenger.showSnackBar(SnackBar(content: Text(doneText)));
  }

  TextStyle get _valueStyle =>
      TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          value,
        ],
      ),
    );
  }
}
