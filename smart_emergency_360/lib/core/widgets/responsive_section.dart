import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Consistent horizontal page padding (see AppTheme.pagePadding), shared so
/// screens don't each hardcode their own EdgeInsets. The app-wide max-width
/// centering for desktop Chrome already lives in MaterialApp.builder
/// (app.dart); this only handles the per-screen inner padding.
class ResponsiveSection extends StatelessWidget {
  final Widget child;
  final double vertical;

  const ResponsiveSection({super.key, required this.child, this.vertical = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: vertical,
      ),
      child: child,
    );
  }
}
