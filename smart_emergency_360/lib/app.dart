import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_dependencies.dart';
import 'core/config/app_config.dart';
import 'core/language/app_language.dart';
import 'core/models/app_notification.dart';
import 'core/models/incident.dart';
import 'core/services/auth_session.dart';
import 'core/services/settings_repository.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/incident_ui.dart';
import 'core/widgets/auth_background.dart';
import 'screens/history/incident_details_screen.dart';
import 'screens/root/root_shell.dart';

class RescueOneApp extends StatefulWidget {
  const RescueOneApp({super.key, required this.dependencies, this.initialHome});

  final AppDependencies dependencies;
  final Widget? initialHome;

  @override
  State<RescueOneApp> createState() => _RescueOneAppState();
}

class _RescueOneAppState extends State<RescueOneApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final Widget _home;
  late bool _darkApplied;

  AppDependencies get deps => widget.dependencies;

  @override
  void initState() {
    super.initState();
    _darkApplied = deps.settings.darkMode;
    AppColors.setDark(_darkApplied);

    // Open straight on Home (RootShell) so every feature (SOS, Hospitals,
    // AI Assistant, Maps) is immediately available upon opening the link.
    _home = widget.initialHome ?? const RootShell();

    deps.notifications.onNew = _showIncidentBanner;
    deps.auth.addListener(_onAuthChanged);
    // A reset link may already have been handled before the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());

    // "Always detect location" setting: locate the user and load nearby
    // hospitals right away. Otherwise this waits until SOS/hospitals.
    if (deps.settings.locationAlwaysOn) {
      deps.hospitals.refresh();
    }
  }

  @override
  void dispose() {
    deps.notifications.onNew = null;
    deps.auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  bool _passwordDialogOpen = false;

  /// The user opened a password-reset link: ask for the new password.
  Future<void> _onAuthChanged() async {
    if (!deps.auth.needsNewPassword || _passwordDialogOpen) return;
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    _passwordDialogOpen = true;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _NewPasswordDialog(),
    );
    _passwordDialogOpen = false;
    if (saved != true) {
      deps.auth.dismissPasswordRecovery();
      return;
    }
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(deps.language.tr('new_password_saved'))),
    );
  }

  /// In-app alert for an incident status change (Settings > Notifications).
  void _showIncidentBanner(AppNotification n) {
    if (!deps.settings.notificationsEnabled) return;
    if (n.status == IncidentStatus.created) return; // the user just did that
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    final lang = deps.language;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(incidentStatusIcon(n.status), color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${lang.tr(incidentTypeKey(n.incidentType))} · '
                  '${lang.tr(incidentStatusKey(n.status))}',
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: lang.tr('notifications_view'),
            onPressed: () => _navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => IncidentDetailsScreen(incidentId: n.incidentId),
              ),
            ),
          ),
        ),
      );
  }

  /// Screens read neutral colors straight from [AppColors], so after the
  /// palette switches every element is rebuilt once (route stack and
  /// screen state are kept).
  void _rebuildEverything() {
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    if (mounted) (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: deps),
        ChangeNotifierProvider.value(value: deps.language),
        ChangeNotifierProvider.value(value: deps.auth),
        ChangeNotifierProvider.value(value: deps.settings),
        ChangeNotifierProvider.value(value: deps.contacts),
        ChangeNotifierProvider.value(value: deps.profile),
        ChangeNotifierProvider.value(value: deps.notifications),
        ChangeNotifierProvider.value(value: deps.incidents),
        ChangeNotifierProvider.value(value: deps.hospitals),
        ChangeNotifierProvider.value(value: deps.nearby),
        ChangeNotifierProvider.value(value: deps.savedPlaces),
        Provider.value(value: deps.location),
      ],
      child: Consumer2<AppLanguage, SettingsRepository>(
        builder: (context, appLanguage, settings, _) {
          if (settings.darkMode != _darkApplied) {
            _darkApplied = settings.darkMode;
            AppColors.setDark(_darkApplied);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _rebuildEverything(),
            );
          }
          return Directionality(
            textDirection: appLanguage.textDirection,
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              scaffoldMessengerKey: _messengerKey,
              debugShowCheckedModeBanner: false,
              title: appLanguage.tr('app_name'),
              theme: AppTheme.current(),
              themeAnimationDuration: Duration.zero,
              locale: appLanguage.materialLocale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Caps content width on wide desktop-browser windows so cards
              // don't stretch edge-to-edge; a no-op on phones.
              // The soft-glow backdrop spans the whole window; opaque
              // screens cover it, the welcome and sign-in screens show it.
              builder: (context, child) => AuthBackground(
                fullWindow: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: child,
                  ),
                ),
              ),
              home: _home,
            ),
          );
        },
      ),
    );
  }
}

/// Shown after a password-reset link brings the user back to the app.
/// Pops true once the new password is saved.
class _NewPasswordDialog extends StatefulWidget {
  const _NewPasswordDialog();

  @override
  State<_NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _errorKey;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _errorKey = null;
    });
    final errorKey = await context.read<AuthSession>().updatePassword(
      _controller.text,
    );
    if (!mounted) return;
    if (errorKey == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _errorKey = errorKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lengthMsg = context.tr('login_validation_password');
    return AlertDialog(
      icon: Icon(Icons.lock_reset_rounded, color: AppColors.primaryBlue),
      title: Text(context.tr('new_password_title')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              obscureText: _obscure,
              autofocus: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: context.tr('new_password_label'),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onFieldSubmitted: (_) => _save(),
              validator: (value) =>
                  (value == null || value.length < AppConfig.minPasswordLength)
                  ? lengthMsg
                  : null,
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: 10),
              Text(
                context.tr(_errorKey!),
                style: TextStyle(color: AppColors.dangerRed, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.tr('save')),
        ),
      ],
    );
  }
}
