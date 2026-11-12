import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Bundled IBM Plex Sans Arabic - one family for Arabic and English.
  static const String fontFamily = 'IBMPlexSansArabic';

  // Shared design tokens - reuse these instead of repeating raw numbers.
  static const double cardRadius = 24;
  static const double inputRadius = 16;
  static const double buttonRadius = 16;
  static const double buttonHeight = 56;
  static const double pagePadding = 20;

  /// Spacing rhythm (8dp grid).
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  /// Motion tokens: quick feedback vs. larger transitions.
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);

  static TextStyle _t(
    double size,
    FontWeight weight, {
    double height = 1.45,
    Color? color,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// Accessible type scale: body text 15-16, nothing below 12. Arabic
  /// needs a taller line height than Latin to stay readable.
  static TextTheme _textTheme() {
    final primary = AppColors.textPrimary;
    final secondary = AppColors.textSecondary;
    return TextTheme(
      displaySmall: _t(30, FontWeight.w700, height: 1.25, color: primary),
      headlineMedium: _t(26, FontWeight.w700, height: 1.3, color: primary),
      headlineSmall: _t(22, FontWeight.w700, height: 1.3, color: primary),
      titleLarge: _t(19, FontWeight.w700, height: 1.35, color: primary),
      titleMedium: _t(16, FontWeight.w600, height: 1.4, color: primary),
      titleSmall: _t(14, FontWeight.w600, height: 1.4, color: primary),
      bodyLarge: _t(16, FontWeight.w400, height: 1.5, color: primary),
      bodyMedium: _t(15, FontWeight.w400, color: primary),
      bodySmall: _t(13, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: _t(15, FontWeight.w600, height: 1.3, color: primary),
      labelMedium: _t(13, FontWeight.w600, height: 1.3, color: primary),
      labelSmall: _t(12, FontWeight.w600, height: 1.3, color: secondary),
    );
  }

  /// Builds the theme for the palette currently active in [AppColors].
  /// Call [AppColors.setDark] first, then this.
  static ThemeData current() {
    final dark = AppColors.isDark;
    final brightness = dark ? Brightness.dark : Brightness.light;
    final textTheme = _textTheme();

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: brightness,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        error: AppColors.dangerRed,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    final buttonText = _t(16, FontWeight.w600, height: 1.2);

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: _t(
          18,
          FontWeight.w700,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: dark ? 0 : 1.5,
        shadowColor: AppColors.primaryBlue.withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: dark
                ? AppColors.border.withValues(alpha: 0.6)
                : AppColors.border.withValues(alpha: 0.55),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _t(
          19,
          FontWeight.w700,
          height: 1.35,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: _t(15, FontWeight.w400, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: _t(15, FontWeight.w500, color: AppColors.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        minVerticalPadding: 10,
        titleTextStyle: _t(15.5, FontWeight.w600, color: AppColors.textPrimary),
        subtitleTextStyle: _t(
          13,
          FontWeight.w400,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: _t(14.5, FontWeight.w600, height: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: _t(14.5, FontWeight.w600, height: 1.2),
          minimumSize: const Size(48, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: _t(15, FontWeight.w400, color: AppColors.textSecondary),
        errorStyle: _t(12.5, FontWeight.w500, height: 1.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.dangerRed, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.subtleFill,
        side: BorderSide(color: AppColors.border),
        labelStyle: _t(
          13,
          FontWeight.w600,
          height: 1.2,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryBlue
              : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF22395A) : AppColors.darkBlue,
        contentTextStyle: _t(14.5, FontWeight.w500, color: Colors.white),
        actionTextColor: AppColors.secondaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: _t(13, FontWeight.w500, height: 1.3, color: Colors.white),
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }
}
