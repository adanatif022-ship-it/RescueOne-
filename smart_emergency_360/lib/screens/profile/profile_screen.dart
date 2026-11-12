import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/services/auth_session.dart';
import '../../core/services/profile_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/display_name.dart';
import '../../core/utils/confirm_logout.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/responsive_section.dart';
import '../contacts/trusted_contacts_screen.dart';
import '../help/help_support_screen.dart';
import '../splash/splash_screen.dart';
import '../history/incident_history_screen.dart';
import '../places/saved_places_screen.dart';
import 'emergency_profile_screen.dart';
import '../settings/settings_screen.dart';

/// Profile hub: identity summary plus shortcuts into every
/// personal-information screen (contacts, medical profile, history,
/// settings, help). Existing session/profile data is reused as-is - no
/// invented real-person identity.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final profile = context.watch<ProfileRepository>().profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('profile_screen_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.primaryBlue,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userDisplayName(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.email ?? context.tr('profile_no_email'),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          if (profile.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            LtrText(
                              profile.phone,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.badge_rounded,
                          label: context.tr('profile_personal_info'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EmergencyProfileScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.contacts_rounded,
                          label: context.tr('home_trusted_contacts'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TrustedContactsScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.bookmark_border_rounded,
                          label: context.tr('profile_saved_places'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SavedPlacesScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.history_rounded,
                          label: context.tr('nav_history'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const IncidentHistoryScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.settings_rounded,
                          label: context.tr('settings_title'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ProfileTile(
                          icon: Icons.help_outline_rounded,
                          label: context.tr('settings_help_support'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await confirmLogout(context);
                      if (!confirmed || !context.mounted) return;
                      await session.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                    icon: Icon(
                      Icons.logout_rounded,
                      color: AppColors.dangerRed,
                    ),
                    label: Text(
                      context.tr('settings_logout'),
                      style: TextStyle(color: AppColors.dangerRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.dangerRed),
                    ),
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
