import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/services/auth_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/language_selector.dart';
import '../../core/widgets/responsive_section.dart';
import '../root/root_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToApp() {
    // Clears Splash + Login/Register from the stack so the back button
    // from inside the app can't land on the pre-auth welcome screen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      await _continueAsGuest();
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    // "Remember me" decides whether the session survives an app restart.
    final errorKey = await context.read<AuthSession>().signIn(
      email,
      _passwordController.text,
      remember: _rememberMe,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (errorKey != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.trRead(errorKey))));
      return;
    }
    _goToApp();
  }

  Future<void> _continueAsGuest() async {
    await context.read<AuthSession>().continueAsGuest(remember: _rememberMe);
    if (mounted) _goToApp();
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  /// Emails a reset link. Opening it brings the user back to the app,
  /// which then asks for a new password (see RescueOneApp).
  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (email == null || !mounted) return;
    final errorKey = await context.read<AuthSession>().sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            context.trRead(errorKey ?? 'login_forgot_password_sent'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Captured here (during build) instead of read inside the validator
    // closures below - FormState.validate() runs those synchronously from
    // the Sign In button's tap handler, outside any build phase, where a
    // listening Provider.of/context.tr call throws.
    final emailValidationMsg = context.tr('login_validation_email');
    final passwordValidationMsg = context.tr('login_validation_password_empty');

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveSection(
              vertical: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back to the welcome screen + language.
                  const Row(
                    children: [AppBackButton(), Spacer(), LanguageSelector()],
                  ),
                  const SizedBox(height: 16),
                  const Center(child: AppLogo(size: 76)),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('login_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('login_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.tr('login_email'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || !value.contains('@')) {
                                    return emailValidationMsg;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('login_password'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) =>
                                    _busy ? null : _signIn(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return passwordValidationMsg;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? true),
                                  ),
                                  Expanded(
                                    child: Text(
                                      context.tr('login_remember_me'),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  // Flexible: inside the card on a narrow
                                  // phone the label wraps instead of
                                  // overflowing (long in English).
                                  Flexible(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      onPressed: _forgotPassword,
                                      child: Text(
                                        context.tr('login_forgot_password'),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GradientButton(
                          label: context.tr('login_button'),
                          icon: Icons.login_rounded,
                          loading: _busy,
                          onPressed: _busy ? null : _signIn,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                context.tr('login_or_divider'),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: AppTheme.buttonHeight,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue.withValues(
                                alpha: AppColors.isDark ? 0.18 : 0.10,
                              ),
                              foregroundColor: AppColors.primaryBlue,
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              context.tr('login_guest'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _continueAsGuest,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _goToRegister,
                          child: Text(context.tr('register_title')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('login_prototype_notice'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for the account email; pops it, or null when cancelled.
class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final emailValidationMsg = context.tr('login_validation_email');
    return AlertDialog(
      icon: Icon(Icons.lock_reset_rounded, color: AppColors.primaryBlue),
      title: Text(context.tr('login_forgot_password')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr('login_forgot_password_body')),
            const SizedBox(height: 14),
            TextFormField(
              controller: _controller,
              autofocus: widget.initialEmail.isEmpty,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              onFieldSubmitted: (_) => _submit(),
              validator: (value) => (value == null || !value.contains('@'))
                  ? emailValidationMsg
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.tr('login_forgot_password_send')),
        ),
      ],
    );
  }
}
