import 'package:flutter/material.dart';
import '../language/app_language.dart';
import '../theme/app_colors.dart';

/// Shared logout confirmation dialog used by Settings and Profile, so
/// signing out always requires an explicit second tap.
Future<bool> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.tr('logout_confirm_title')),
      content: Text(dialogContext.tr('logout_confirm_body')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
          child: Text(dialogContext.tr('settings_logout')),
        ),
      ],
    ),
  );
  return confirmed == true;
}
