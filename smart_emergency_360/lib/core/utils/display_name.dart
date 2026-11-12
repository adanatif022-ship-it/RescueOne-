import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../language/app_language.dart';
import '../services/auth_session.dart';
import '../services/profile_repository.dart';

/// The name shown in greetings and profile headers: the registered name,
/// else the name from the emergency profile, else the email for a signed-in
/// account, else "Guest". Rebuilds the caller when any of these change.
String userDisplayName(BuildContext context) {
  final session = context.watch<AuthSession>();
  final profileName = context.watch<ProfileRepository>().profile.fullName;
  final registered = session.realName;
  if (registered != null && registered.isNotEmpty) return registered;
  if (profileName.trim().isNotEmpty) return profileName.trim();
  if (!session.isGuest && session.email != null) return session.email!;
  return context.tr('guest_label');
}
