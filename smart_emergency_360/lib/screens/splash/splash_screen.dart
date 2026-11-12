import 'package:flutter/material.dart';
import '../../core/language/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/language_selector.dart';
import '../../core/widgets/responsive_section.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../root/root_shell.dart';
import '../sos/emergency_type_screen.dart';

/// Welcome screen: brand mark, tagline, the four emergency categories,
/// Sign In / Create Account - plus an SOS button that works without any
/// account, because someone in an emergency shouldn't have to sign in
/// first. (Once signed in or in guest mode, the app opens on Home.)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundPattern(),
          SafeArea(
            // Scrolls on short screens / landscape; on normal phones the
            // Spacers still spread the content over the full height.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: ResponsiveSection(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: const LanguageSelector(),
                          ),
                          const Spacer(),
                          const AppLogo(size: 108),
                          const SizedBox(height: 20),
                          Text(
                            context.tr('app_name'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('splash_tagline'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const _ServiceIconsRow(),
                          const Spacer(),
                          const _SosNowButton(),
                          const SizedBox(height: 14),
                          GradientButton(
                            label: context.lang.isArabic
                                ? 'الدخول إلى الصفحة الرئيسية'
                                : 'Enter Home Page',
                            icon: Icons.home_rounded,
                            onPressed: () =>
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const RootShell(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: AppTheme.buttonHeight,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.login_rounded),
                              label: Text(context.tr('login_button')),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: Text(context.tr('register_title')),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceIconsRow extends StatelessWidget {
  const _ServiceIconsRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.medical_services_rounded, context.tr('splash_services_medical')),
      (Icons.local_police_rounded, context.tr('splash_services_police')),
      (Icons.local_fire_department_rounded, context.tr('splash_services_fire')),
      (Icons.shield_rounded, context.tr('splash_services_protection')),
    ];
    // Each item gets an equal share of the width and its label may wrap -
    // fixed-width labels overflowed on 360-px-wide phones.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.$1,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Soft circular technology-pattern backdrop - decorative only, kept far
/// below the interactive content in the stack so it never intercepts taps.
class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _softCircle(
              240,
              AppColors.primaryBlue.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: 120,
            left: -100,
            child: _softCircle(
              200,
              AppColors.secondaryBlue.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _softCircle(
              260,
              AppColors.brightBlue.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: _softCircle(
              160,
              AppColors.softPurple.withValues(alpha: 0.06),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// One-tap SOS straight from the welcome screen - no sign-in needed.
class _SosNowButton extends StatelessWidget {
  const _SosNowButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EmergencyTypeScreen())),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.dangerRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            border: Border.all(
              color: AppColors.dangerRed.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('splash_sos_now'),
                      style: TextStyle(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      context.tr('splash_sos_hint'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Mirrors automatically in Arabic (matchTextDirection).
              Icon(Icons.chevron_right_rounded, color: AppColors.dangerRed),
            ],
          ),
        ),
      ),
    );
  }
}
