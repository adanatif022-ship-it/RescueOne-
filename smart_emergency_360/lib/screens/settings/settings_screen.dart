import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app_dependencies.dart';
import '../../core/config/app_config.dart';
import '../../core/language/app_language.dart';
import '../../core/services/auth_session.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/display_name.dart';
import '../../core/utils/confirm_logout.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/responsive_section.dart';
import '../contacts/trusted_contacts_screen.dart';
import '../help/help_support_screen.dart';
import '../profile/emergency_profile_screen.dart';
import '../splash/splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editEmergencyNumber(
    BuildContext context,
    SettingsRepository settings,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EmergencyNumberDialog(current: settings.emergencyNumber),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trRead('settings_emergency_number_saved')),
        ),
      );
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.delete_forever_rounded,
          color: AppColors.dangerRed,
          size: 32,
        ),
        title: Text(dialogContext.tr('settings_delete_all')),
        content: Text(dialogContext.tr('settings_delete_all_confirm_body')),
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
    final deps = context.read<AppDependencies>();
    final messenger = ScaffoldMessenger.of(context);
    final doneText = context.trRead('settings_delete_all_done');
    final navigator = Navigator.of(context);
    await deps.deleteAllData();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
    messenger.showSnackBar(SnackBar(content: Text(doneText)));
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppLanguage>();
    final session = context.watch<AuthSession>();
    final settings = context.watch<SettingsRepository>();

    Widget sectionLabel(String key) => Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8, top: 20),
      child: Text(
        context.tr(key),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );

    Widget icon(IconData data, {Color? color}) =>
        Icon(data, color: color ?? AppColors.primaryBlue);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('settings_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sectionLabel('settings_account'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userDisplayName(context),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (session.email != null)
                                  LtrText(
                                    session.email!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: icon(Icons.badge_rounded),
                          title: Text(context.tr('settings_profile')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EmergencyProfileScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: icon(Icons.contacts_rounded),
                          title: Text(context.tr('settings_contacts')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TrustedContactsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sectionLabel('settings_language'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _LanguageOption(
                              label: context.tr('settings_english'),
                              selected: !appLanguage.isArabic,
                              onTap: () => appLanguage.setLocale(AppLocale.en),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LanguageOption(
                              label: context.tr('settings_arabic'),
                              selected: appLanguage.isArabic,
                              onTap: () => appLanguage.setLocale(AppLocale.ar),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sectionLabel('settings_emergency_number'),
                  Card(
                    child: ListTile(
                      leading: icon(
                        Icons.emergency_rounded,
                        color: AppColors.dangerRed,
                      ),
                      title: Row(
                        children: [
                          Text(context.tr('settings_emergency_number')),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: LtrText(
                              settings.emergencyNumber,
                              style: TextStyle(
                                color: AppColors.dangerRed,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        context.tr('settings_emergency_number_hint'),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      trailing: const Icon(Icons.edit_rounded, size: 20),
                      onTap: () => _editEmergencyNumber(context, settings),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: icon(Icons.notifications_none_rounded),
                          title: Text(context.tr('settings_notifications')),
                          subtitle: Text(
                            context.tr('settings_notifications_hint'),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          value: settings.notificationsEnabled,
                          onChanged: settings.setNotificationsEnabled,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: icon(Icons.volume_off_rounded),
                          title: Text(context.tr('settings_silent_mode')),
                          subtitle: Text(
                            context.tr('settings_silent_mode_hint'),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          value: settings.silentModeDefault,
                          onChanged: settings.setSilentModeDefault,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: icon(
                            settings.darkMode
                                ? Icons.dark_mode_rounded
                                : Icons.dark_mode_outlined,
                          ),
                          title: Text(context.tr('settings_dark_mode')),
                          subtitle: Text(
                            context.tr('settings_dark_mode_hint'),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          value: settings.darkMode,
                          onChanged: settings.setDarkMode,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: icon(Icons.location_on_outlined),
                          title: Text(context.tr('settings_location_settings')),
                          subtitle: Text(
                            settings.locationAlwaysOn
                                ? context.tr('settings_location_always_on')
                                : context.tr('settings_location_only_sos'),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          value: settings.locationAlwaysOn,
                          onChanged: (v) async {
                            await settings.setLocationAlwaysOn(v);
                            if (v && context.mounted) {
                              context.read<HospitalRepository>().refresh();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: icon(Icons.privacy_tip_outlined),
                          title: Text(context.tr('settings_privacy_security')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(
                                dialogContext.tr('settings_privacy_security'),
                              ),
                              content: Text(
                                dialogContext.tr(
                                  'settings_privacy_security_body',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: Text(dialogContext.tr('ok')),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: icon(Icons.help_outline_rounded),
                          title: Text(context.tr('settings_help_support')),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sectionLabel('settings_data'),
                  Card(
                    child: ListTile(
                      leading: icon(
                        Icons.delete_sweep_rounded,
                        color: AppColors.dangerRed,
                      ),
                      title: Text(
                        context.tr('settings_delete_all'),
                        style: TextStyle(color: AppColors.dangerRed),
                      ),
                      onTap: () => _deleteAllData(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('settings_about_title'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('settings_about_body'),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'v1.1.0',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.subtleFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Presets (999 / 112 / 911) or a custom 2-6 digit number.
class _EmergencyNumberDialog extends StatefulWidget {
  final String current;
  const _EmergencyNumberDialog({required this.current});

  @override
  State<_EmergencyNumberDialog> createState() => _EmergencyNumberDialogState();
}

class _EmergencyNumberDialogState extends State<_EmergencyNumberDialog> {
  late String _selected = widget.current;
  late final _custom = TextEditingController(
    text: AppConfig.emergencyNumberPresets.contains(widget.current)
        ? ''
        : widget.current,
  );
  late bool _useCustom = !AppConfig.emergencyNumberPresets.contains(
    widget.current,
  );
  String? _error;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _useCustom ? _custom.text.trim() : _selected;
    final ok = await context.read<SettingsRepository>().setEmergencyNumber(
      number,
    );
    if (!mounted) return;
    if (!ok) {
      setState(
        () => _error = context.trRead('settings_emergency_number_invalid'),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('settings_emergency_number')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('settings_emergency_number_hint'),
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final preset in AppConfig.emergencyNumberPresets)
                  ChoiceChip(
                    label: Text(preset),
                    selected: !_useCustom && _selected == preset,
                    onSelected: (_) => setState(() {
                      _useCustom = false;
                      _selected = preset;
                      _error = null;
                    }),
                  ),
                ChoiceChip(
                  label: Text(context.tr('settings_emergency_number_custom')),
                  selected: _useCustom,
                  onSelected: (_) => setState(() => _useCustom = true),
                ),
              ],
            ),
            if (_useCustom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _custom,
                autofocus: true,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(errorText: _error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}
