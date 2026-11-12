import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../language/app_language.dart';
import '../theme/app_colors.dart';

/// Shared pill-style language selector (globe icon + current language +
/// chevron) used on Splash/Login/Register instead of each screen rolling
/// its own toggle button.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppLanguage>();
    return PopupMenuButton<AppLocale>(
      initialValue: appLanguage.locale,
      onSelected: (locale) => appLanguage.setLocale(locale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      // itemBuilder runs synchronously inside showButtonMenu(), called
      // directly from this button's own tap handler - NOT during a route's
      // build phase (unlike showDialog's builder). A listening context.tr
      // there throws the same "Provider read outside the widget tree"
      // assertion as calling it from any other event handler.
      itemBuilder: (menuContext) => [
        PopupMenuItem(
          value: AppLocale.en,
          child: Text(menuContext.trRead('settings_english')),
        ),
        PopupMenuItem(
          value: AppLocale.ar,
          child: Text(menuContext.trRead('settings_arabic')),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 6),
            Text(
              appLanguage.isArabic
                  ? context.tr('settings_arabic')
                  : context.tr('settings_english'),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
