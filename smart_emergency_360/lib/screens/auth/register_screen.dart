import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/language/app_language.dart';
import '../../core/services/auth_backend.dart';
import '../../core/services/auth_session.dart';
import '../../core/services/profile_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/language_selector.dart';
import '../../core/widgets/responsive_section.dart';
import '../root/root_shell.dart';

/// Creates a real account (Supabase Auth, see AuthSession.register). When
/// the project requires email confirmation, the user is told to open the
/// emailed link and is sent back to the sign-in screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _termsTouched = false;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _termsTouched = true);
    final formValid = _formKey.currentState!.validate();
    if (!formValid || !_agreedToTerms) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    setState(() => _busy = true);
    final RegisterOutcome outcome;
    try {
      outcome = await context.read<AuthSession>().register(
        name,
        email,
        phone,
        _passwordController.text,
      );
    } on AuthFailure catch (f) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.trRead(f.key))));
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    // Pre-fill the emergency medical profile with what was just typed, so
    // responders see a name and number even if the profile is never opened.
    final profileRepo = context.read<ProfileRepository>();
    final profile = profileRepo.profile;
    if (profile.fullName.isEmpty || profile.phone.isEmpty) {
      await profileRepo.saveProfile(
        profile.copyWith(
          fullName: profile.fullName.isEmpty ? name : null,
          phone: profile.phone.isEmpty ? phone : null,
        ),
      );
    }
    if (!mounted) return;
    if (outcome == RegisterOutcome.confirmEmail) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primaryBlue,
          ),
          title: Text(dialogContext.tr('register_confirm_email_title')),
          content: Text(
            dialogContext.trArgs('register_confirm_email_body', {
              'email': email,
            }),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.tr('ok')),
            ),
          ],
        ),
      );
      // Back to sign-in once the email is confirmed.
      if (mounted) Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Captured during build - see login_screen.dart for why validators
    // can't call context.tr directly (they run outside the build phase).
    final nameValidationMsg = context.tr('register_validation_name');
    final emailValidationMsg = context.tr('login_validation_email');
    final phoneValidationMsg = context.tr('register_validation_phone');
    final passwordValidationMsg = context.tr('login_validation_password');
    final confirmPasswordValidationMsg = context.tr(
      'register_validation_confirm_password',
    );

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(context.tr('register_title')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: Center(child: LanguageSelector()),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveSection(
              vertical: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 64)),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('register_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                                context.tr('register_full_name'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? nameValidationMsg
                                    : null,
                              ),
                              const SizedBox(height: 16),
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
                                decoration: const InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) =>
                                    (value == null || !value.contains('@'))
                                    ? emailValidationMsg
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('register_phone'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.call_outlined),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().length < 6)
                                    ? phoneValidationMsg
                                    : null,
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
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null ||
                                        value.length <
                                            AppConfig.minPasswordLength)
                                    ? passwordValidationMsg
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('register_confirm_password'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    (value != _passwordController.text)
                                    ? confirmPasswordValidationMsg
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (v) => setState(
                                      () => _agreedToTerms = v ?? false,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      context.tr('register_terms'),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              if (_termsTouched && !_agreedToTerms)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 12,
                                    top: 2,
                                  ),
                                  child: Text(
                                    context.tr('register_validation_terms'),
                                    style: TextStyle(
                                      color: AppColors.dangerRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: context.tr('register_button'),
                          icon: Icons.person_add_alt_1_rounded,
                          loading: _busy,
                          onPressed: _busy ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('register_already_have_account'),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.tr('login_button')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('register_prototype_notice'),
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
