import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/services/notifications_repository.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/ltr_text.dart';
import '../history/incident_details_screen.dart';

/// In-app notification center: one entry per incident status change.
/// Opening it marks everything as read.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = context.read<NotificationsRepository>();
  }

  @override
  void dispose() {
    // Everything that was on screen has now been seen.
    _repo.markAllRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<NotificationsRepository>();
    final alertsOn = context.watch<SettingsRepository>().notificationsEnabled;
    final items = repo.items;
    final isArabic = context.lang.isArabic;
    final timeFormat = DateFormat('d MMM, HH:mm', isArabic ? 'ar' : 'en');

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notifications_title')),
        actions: [
          if (items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') repo.markAllRead();
                if (value == 'clear') repo.clear();
              },
              itemBuilder: (menuContext) => [
                PopupMenuItem(
                  value: 'read',
                  child: Text(menuContext.trRead('notifications_mark_read')),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text(menuContext.trRead('notifications_clear')),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (!alertsOn) ...[
            const DisclaimerBanner(
              textKey: 'notifications_disabled_hint',
              icon: Icons.notifications_off_outlined,
            ),
            const SizedBox(height: 12),
          ],
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
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
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('notifications_empty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...items.map((n) {
              final color = incidentStatusColor(n.status);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(
                        incidentStatusIcon(n.status),
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      context.tr(incidentStatusKey(n.status)),
                      style: TextStyle(
                        fontWeight: n.read ? FontWeight.w500 : FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${context.tr(incidentTypeKey(n.incidentType))} · '
                      '${ltrIsolate(n.incidentId)} · ${timeFormat.format(n.time)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: n.read
                        ? null
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            IncidentDetailsScreen(incidentId: n.incidentId),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
