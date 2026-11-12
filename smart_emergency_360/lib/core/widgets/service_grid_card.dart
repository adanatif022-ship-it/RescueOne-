import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'service_icon.dart';

/// Shared large icon/title/(optional subtitle) card with a selectable
/// state, used for the Home quick services and the emergency-type grid.
///
/// Put it in a grid with a fixed row height ([ServiceGridCard.gridDelegate])
/// rather than an aspect ratio: the old `childAspectRatio: 1.5` gave the
/// card ~103 px on 360-px-wide phones while its content needed ~121 px,
/// so Flutter drew overflow stripes and cut the service name off.
class ServiceGridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? _color;
  Color get color => _color ?? AppColors.primaryBlue;
  final bool selected;
  final VoidCallback onTap;

  const ServiceGridCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this._color,
    this.selected = false,
  });

  /// Two columns with a fixed row height that fits the content on any
  /// phone width.
  static SliverGridDelegate gridDelegate({required bool withSubtitle}) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: withSubtitle ? 168 : 128,
      );

  @override
  Widget build(BuildContext context) {
    final iconBox = subtitle == null ? 50.0 : 52.0;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      // The decoration (with its shadow) sits outside the Material so the
      // shadow isn't clipped by it; the ripple is drawn on the Material.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.22),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? color : AppColors.primaryBlue).withValues(
                alpha: selected ? 0.28 : (AppColors.isDark ? 0.0 : 0.08),
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            onTap: onTap,
            // Very large accessibility font sizes are capped inside the
            // card so the fixed-height grid row can never overflow.
            child: Stack(
              children: [
                if (selected)
                  // Check mark: the selection isn't shown by color alone.
                  PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, size: 17, color: color),
                    ),
                  ),
                Positioned.fill(
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.25,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ServiceIcon(
                            icon: icon,
                            color: color,
                            size: iconBox,
                            inverted: selected,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: subtitle == null ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.88)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
