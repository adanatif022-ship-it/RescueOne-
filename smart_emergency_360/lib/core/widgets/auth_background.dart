import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Welcome / sign-in / sign-up background ("soft glow"): a calm ground with
/// two soft color glows - brand blue in the top corner, emergency red in the
/// opposite bottom corner. Screens wrap their (transparent) Scaffold in it.
///
/// The app also paints it once behind everything ([fullWindow], app.dart),
/// so on a wide browser window the glow fills the whole window instead of
/// stopping at the edges of the centered phone-width column; screens inside
/// then simply let that backdrop show through.
class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
    this.fullWindow = false,
  });

  final Widget child;
  final bool fullWindow;

  @override
  Widget build(BuildContext context) {
    if (!fullWindow &&
        context.dependOnInheritedWidgetOfExactType<_GlowScope>() != null) {
      return child;
    }
    final dark = AppColors.isDark;
    final glow = Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: dark ? const Color(0xFF0A1424) : const Color(0xFFF7F9FC),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.85, -0.9),
                radius: 1.0,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: dark ? 0.24 : 0.26),
                  AppColors.primaryBlue.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.95, 0.95),
                radius: 0.85,
                colors: [
                  AppColors.vividDangerRed.withValues(
                    alpha: dark ? 0.12 : 0.16,
                  ),
                  AppColors.vividDangerRed.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
    return fullWindow ? _GlowScope(child: glow) : glow;
  }
}

/// Marks that the full-window glow is already painted above this point.
class _GlowScope extends InheritedWidget {
  const _GlowScope({required super.child});

  @override
  bool updateShouldNotify(_GlowScope oldWidget) => false;
}

/// The frosted card that holds the sign-in / sign-up form.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.surface.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.95),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062B4F).withValues(alpha: dark ? 0.3 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
