import 'package:flutter/material.dart';
import '../language/app_language.dart';
import '../theme/app_colors.dart';

/// A visible, non-dismissible-feeling warning banner. Used everywhere the
/// app shows simulated/prototype data so it is never mistaken for a live
/// feed (see the "safety requirements" - never claim simulated data is real).
class DisclaimerBanner extends StatelessWidget {
  final String textKey;
  final IconData icon;

  const DisclaimerBanner({
    super.key,
    required this.textKey,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(textKey),
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
