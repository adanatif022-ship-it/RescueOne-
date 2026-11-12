import 'package:flutter/material.dart';

/// Central brand palette for Rescue One.
/// Keep every screen on these colors instead of ad-hoc hex values.
///
/// Brand/status colors are fixed. Neutral colors (text, background,
/// surfaces, borders) are getters that follow the current light/dark mode,
/// so every screen switches theme without per-screen code. [setDark] is
/// called by the app root whenever the Dark Mode setting changes.
class AppColors {
  AppColors._();

  static bool _dark = false;

  /// Whether the dark palette is active.
  static bool get isDark => _dark;

  /// Switches the neutral palette. The app root rebuilds every widget
  /// right after calling this (see `app.dart`).
  static void setDark(bool value) => _dark = value;

  // ------------------------------------------------------------ brand
  /// Brand blue. Slightly deeper in light mode so white button text and
  /// blue links on light backgrounds reach the 4.5:1 contrast minimum;
  /// the original #0D8BFF already reads well on dark surfaces.
  static Color get primaryBlue =>
      _dark ? const Color(0xFF0D8BFF) : const Color(0xFF0A6FD8);
  static const Color secondaryBlue = Color(0xFF4FC3F7);
  static const Color darkBlue = Color(0xFF062B4F);

  /// Emergency red - reserved for SOS/call/cancel. Deeper in light mode
  /// for 4.5:1 contrast with white text and as text on white.
  static Color get dangerRed =>
      _dark ? const Color(0xFFE53935) : const Color(0xFFD32F2F);
  static const Color brightBlue = Color(0xFF1C6CFF);
  static const Color deepNavy = Color(0xFF031B3D);

  /// The spec's "Danger Red" accent (badges/glows) - distinct from
  /// [dangerRed] ("Emergency Red"), which stays reserved for real
  /// call/emergency actions so the two aren't visually interchangeable.
  static const Color vividDangerRed = Color(0xFFFF2055);
  static Color get emergencyRed => dangerRed;
  static const Color softPurple = Color(0xFF8A8AFF);

  // ----------------------------------------------------------- status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);

  // Hospital congestion levels - used as *text*, so each has a readable
  // shade per theme (plain yellow on white is only ~1.9:1).
  static Color get congestionLow =>
      _dark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
  static Color get congestionModerate =>
      _dark ? const Color(0xFFF9A825) : const Color(0xFF9A5B00);
  static Color get congestionHigh =>
      _dark ? const Color(0xFFEF5350) : const Color(0xFFC62828);

  // ---------------------------------------------- neutrals (themed)
  /// Page background.
  static Color get background =>
      _dark ? const Color(0xFF0A1424) : const Color(0xFFF6FAFF);

  /// Cards, inputs, sheets, bottom bar.
  static Color get surface =>
      _dark ? const Color(0xFF13233A) : const Color(0xFFFFFFFF);

  /// Subtle filled chips/tags/unselected toggles.
  static Color get subtleFill =>
      _dark ? const Color(0xFF1B2E48) : const Color(0xFFF0F5FA);

  /// Input/card outlines.
  static Color get border =>
      _dark ? const Color(0xFF29405C) : const Color(0xFFD7E6F5);

  /// Divider lines.
  static Color get divider =>
      _dark ? const Color(0xFF223650) : const Color(0xFFE3EEF9);

  /// Not-yet-reached steps in the incident timeline.
  static Color get timelineInactive =>
      _dark ? const Color(0xFF34506F) : const Color(0xFFC9D9E8);

  static Color get textPrimary => _dark ? const Color(0xFFE7F0FA) : darkBlue;

  static Color get textSecondary =>
      _dark ? const Color(0xFF93AECA) : const Color(0xFF5A7A94);
}
