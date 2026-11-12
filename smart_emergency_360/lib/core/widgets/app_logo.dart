import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared brand mark: a blue heart-with-pulse badge with a small red
/// medical-cross accent, matching the approved design reference. Built
/// entirely from Flutter shapes/icons (no image asset exists for it), so
/// it scales cleanly for the splash hero, login/register header, and any
/// smaller in-app usage via [size].
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.34;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.brightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.35),
                  blurRadius: size * 0.28,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.monitor_heart_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
            ),
          ),
          Positioned(
            right: -badgeSize * 0.18,
            bottom: -badgeSize * 0.18,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.vividDangerRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.03),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: badgeSize * 0.62,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
