import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Standardized card padding/optional highlight glow, on top of the
/// already-premium global CardTheme (radius/shadow) - reuse this instead
/// of hand-rolling Card+Padding+glow-Container in individual screens.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;

  const PremiumCard({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: highlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              side: BorderSide(color: AppColors.primaryBlue, width: 1.6),
            )
          : null,
      child: Padding(padding: padding, child: child),
    );

    if (!highlighted) return card;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: card,
    );
  }
}
