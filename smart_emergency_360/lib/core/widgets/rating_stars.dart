import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Simple 1-5 tappable star rating, shared by the Assistance Completed
/// screen (and anywhere else a prototype satisfaction rating is needed).
class RatingStars extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const RatingStars({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = starValue <= value;
        return IconButton(
          onPressed: () => onChanged(starValue),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? AppColors.warning : AppColors.textSecondary,
            size: size,
          ),
        );
      }),
    );
  }
}
