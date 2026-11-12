import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/models/incident.dart';
import '../../core/services/incident_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/responsive_section.dart';
import 'incident_details_screen.dart';

enum _HistoryFilter { all, active, completed, cancelled }

bool _matchesFilter(Incident incident, _HistoryFilter filter) {
  switch (filter) {
    case _HistoryFilter.all:
      return true;
    case _HistoryFilter.active:
      return incident.status.isOpen;
    case _HistoryFilter.completed:
      return incident.status.isFinished;
    case _HistoryFilter.cancelled:
      return incident.status == IncidentStatus.cancelled;
  }
}

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final allIncidents = context.watch<IncidentRepository>().incidents;
    final incidents = allIncidents
        .where((i) => _matchesFilter(i, _filter))
        .toList();
    final isArabic = context.lang.isArabic;
    final dateFormat = DateFormat('d MMM, HH:mm', isArabic ? 'ar' : 'en');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(context.tr('history_title')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: context.tr('history_filter_all'),
                      selected: _filter == _HistoryFilter.all,
                      onTap: () => setState(() => _filter = _HistoryFilter.all),
                    ),
                    _FilterChip(
                      label: context.tr('history_filter_active'),
                      selected: _filter == _HistoryFilter.active,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.active),
                    ),
                    _FilterChip(
                      label: context.tr('history_filter_completed'),
                      selected: _filter == _HistoryFilter.completed,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.completed),
                    ),
                    _FilterChip(
                      label: context.tr('history_filter_cancelled'),
                      selected: _filter == _HistoryFilter.cancelled,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.cancelled),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: incidents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                size: 34,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('history_empty'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ResponsiveSection(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: incidents.length,
                        itemBuilder: (context, index) {
                          final incident = incidents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => IncidentDetailsScreen(
                                      incidentId: incident.id,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            incidentTypeIcon(incident.type),
                                            color: AppColors.primaryBlue,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.tr(
                                                    incidentTypeKey(
                                                      incident.type,
                                                    ),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                LtrText(
                                                  incident.id,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _StatusChip(status: incident.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dateFormat.format(incident.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _Tag(
                                            icon:
                                                incident.mode ==
                                                    AlertMode.silent
                                                ? Icons.volume_off_rounded
                                                : Icons.campaign_rounded,
                                            label:
                                                incident.mode ==
                                                    AlertMode.silent
                                                ? context.tr(
                                                    'history_mode_silent',
                                                  )
                                                : context.tr(
                                                    'history_mode_normal',
                                                  ),
                                          ),
                                          _Tag(
                                            icon: incident.location != null
                                                ? Icons.location_on_rounded
                                                : Icons.location_off_rounded,
                                            label: incident.location != null
                                                ? context.tr(
                                                    'sos_confirm_location_yes',
                                                  )
                                                : context.tr(
                                                    'sos_confirm_location_no',
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IncidentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = incidentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.tr(incidentStatusKey(status)),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.subtleFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
