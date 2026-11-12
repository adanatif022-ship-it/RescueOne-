import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../language/app_language.dart';
import '../models/incident.dart';
import '../theme/app_colors.dart';
import '../utils/incident_ui.dart';

/// Vertical timeline showing all 7 incident stages, with the ones
/// at-or-before [currentStatus] marked as reached, and the time each one
/// was reached when [times] is given.
class StatusTimeline extends StatelessWidget {
  final IncidentStatus currentStatus;
  final Map<IncidentStatus, DateTime> times;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
    this.times = const {},
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = currentStatus.step;
    final timeFormat = DateFormat(
      'HH:mm:ss',
      context.lang.isArabic ? 'ar' : 'en',
    );
    return Column(
      children: [
        for (var i = 0; i < incidentStatusOrder.length; i++)
          _TimelineRow(
            label: context.tr(incidentStatusKey(incidentStatusOrder[i])),
            time: i <= currentStep && times[incidentStatusOrder[i]] != null
                ? timeFormat.format(times[incidentStatusOrder[i]]!)
                : null,
            reached: i <= currentStep,
            isCurrent: i == currentStep,
            isLast: i == incidentStatusOrder.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String? time;
  final bool reached;
  final bool isCurrent;
  final bool isLast;

  const _TimelineRow({
    required this.label,
    required this.time,
    required this.reached,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = reached ? AppColors.primaryBlue : AppColors.timelineInactive;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 18 : 14,
                height: isCurrent ? 18 : 14,
                decoration: BoxDecoration(
                  color: reached ? color : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: reached && !isCurrent
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: reached
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (time != null)
                    Text(
                      time!,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
