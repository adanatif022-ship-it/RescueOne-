import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The official Rescue One logo (assets/images/logo.png - the same file as
/// the website's logo), on a white disc so its colors read the same in
/// light and dark mode.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rescue One',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.07),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            width: size * 0.025,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.18),
              blurRadius: size * 0.28,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
