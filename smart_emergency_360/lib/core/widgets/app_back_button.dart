import 'package:flutter/material.dart';

/// Lets screens shown as bottom-bar tabs (Hospitals, Assistant, History)
/// know which tab is active and go back to Home.
class RootTabsScope extends InheritedWidget {
  final int index;
  final VoidCallback goHome;

  const RootTabsScope({
    super.key,
    required this.index,
    required this.goHome,
    required super.child,
  });

  static RootTabsScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RootTabsScope>();

  @override
  bool updateShouldNotify(RootTabsScope oldWidget) => index != oldWidget.index;
}

/// Back arrow for app bars that works everywhere:
/// * a normally opened page -> goes back to the previous page;
/// * a bottom-bar tab other than Home -> returns to the Home tab;
/// * [onPressed] given -> custom action (e.g. "back to Home" after SOS).
/// The arrow flips automatically in Arabic. Shows nothing on Home itself.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AppBackButton({super.key, this.onPressed});

  /// Whether [AppBackButton] would show an arrow here - for app bars that
  /// need to know if a leading widget is present.
  static bool isAvailable(BuildContext context) {
    if (Navigator.of(context).canPop()) return true;
    final tabs = RootTabsScope.maybeOf(context);
    return tabs != null && tabs.index != 0;
  }

  @override
  Widget build(BuildContext context) {
    if (onPressed != null) return BackButton(onPressed: onPressed);
    if (Navigator.of(context).canPop()) return const BackButton();
    final tabs = RootTabsScope.maybeOf(context);
    if (tabs != null && tabs.index != 0) {
      return BackButton(onPressed: tabs.goHome);
    }
    return const SizedBox.shrink();
  }
}
