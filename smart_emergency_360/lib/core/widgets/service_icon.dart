import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The app's emergency-service icon: a filled circle in the service's color
/// (AppColors.service*) with a white symbol. Used on the welcome screen,
/// Home's quick services and the SOS type grid so they always match.
/// [inverted] = white circle with a colored symbol, for a card that is
/// itself filled with the service color (the selected SOS type).
class ServiceIcon extends StatelessWidget {
  const ServiceIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.inverted = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? Colors.white : color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: inverted
                ? Colors.black.withValues(alpha: 0.12)
                : color.withValues(alpha: AppColors.isDark ? 0.25 : 0.38),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: inverted ? color : Colors.white,
        size: size * 0.52,
      ),
    );
  }
}
