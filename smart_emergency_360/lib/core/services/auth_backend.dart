import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The signed-in account as the app needs it.
class AuthUserInfo {
  final String email;
  final String? name;
  final String? phone;

  const AuthUserInfo({required this.email, this.name, this.phone});
}

/// Account changes that happen outside a direct call, e.g. an email link
/// opened in the browser or a session the server revoked.
enum AuthBackendEvent { signedIn, signedOut, passwordRecovery, userUpdated }

/// A failed account operation. [key] is a translation key that explains
/// the problem to the user.
class AuthFailure implements Exception {
  final String key;
  const AuthFailure(this.key);

  @override
  String toString() => 'AuthFailure($key)';
}

/// Where accounts live. [SupabaseAuthBackend] in the app; tests use a fake.
abstract class AuthBackend {
  AuthUserInfo? get currentUser;
  Stream<AuthBackendEvent> get events;

  /// Throws [AuthFailure].
  Future<AuthUserInfo> signIn(String email, String password);

  /// Returns the new account when it is signed in right away, or null when
  /// the project requires the email to be confirmed first. Throws
  /// [AuthFailure].
  Future<AuthUserInfo?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  /// Throws [AuthFailure].
  Future<void> sendPasswordReset(String email);

  /// Sets a new password for the signed-in account. Throws [AuthFailure].
  Future<void> updatePassword(String newPassword);

  Future<void> signOut();
}

/// Real accounts with Supabase Auth (email + password).
///
/// Every method turns Supabase/network errors into [AuthFailure] with a
/// translation key. If Supabase failed to start, accounts report
/// `auth_error_unavailable` while the rest of the app (SOS included) keeps
/// working.
class SupabaseAuthBackend implements AuthBackend {
  GoTrueClient? get _auth {
    try {
      return Supabase.instance.client.auth;
    } catch (_) {
      return null; // Supabase.initialize didn't run or failed.
    }
  }

  GoTrueClient get _requireAuth {
    final auth = _auth;
    if (auth == null) throw const AuthFailure('auth_error_unavailable');
    return auth;
  }

  /// Email links (confirm account, reset password) come back to the page
  /// that sent them on the web. On a phone they open the project's Site URL
  /// (the web app) in the browser instead.
  String? get _redirectUrl =>
      kIsWeb ? '${Uri.base.origin}${Uri.base.path}' : null;

  static AuthUserInfo _toInfo(User user) {
    final meta = user.userMetadata ?? const {};
    String? text(String key) {
      final value = meta[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return AuthUserInfo(
      email: user.email ?? '',
      name: text('full_name'),
      phone: text('phone'),
    );
  }

  @override
  AuthUserInfo? get currentUser {
    final user = _auth?.currentUser;
    return user == null ? null : _toInfo(user);
  }

  @override
  Stream<AuthBackendEvent> get events {
    final auth = _auth;
    if (auth == null) return const Stream.empty();
    return auth.onAuthStateChange
        .map(
          (state) => switch (state.event) {
            AuthChangeEvent.signedIn => AuthBackendEvent.signedIn,
            AuthChangeEvent.signedOut => AuthBackendEvent.signedOut,
            AuthChangeEvent.passwordRecovery =>
              AuthBackendEvent.passwordRecovery,
            AuthChangeEvent.userUpdated => AuthBackendEvent.userUpdated,
            _ => null,
          },
        )
        .where((e) => e != null)
        .cast<AuthBackendEvent>()
        // A failed token refresh surfaces as a stream error - ignore it here,
        // a real sign-out arrives as its own event.
        .handleError((Object _) {});
  }

  @override
  Future<AuthUserInfo> signIn(String email, String password) =>
      _guard(() async {
        final response = await _requireAuth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = response.user;
        if (user == null) throw const AuthFailure('auth_error_unknown');
        return _toInfo(user);
      });

  @override
  Future<AuthUserInfo?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) => _guard(() async {
    final response = await _requireAuth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectUrl,
      data: {'full_name': name, 'phone': phone},
    );
    final user = response.user;
    // With "Confirm email" on, Supabase answers an already-registered
    // address with a user that has no identities instead of an error.
    if (user != null && (user.identities?.isEmpty ?? false)) {
      throw const AuthFailure('auth_error_user_exists');
    }
    if (response.session == null || user == null) return null;
    return _toInfo(user);
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(
    () => _requireAuth.resetPasswordForEmail(email, redirectTo: _redirectUrl),
  );

  @override
  Future<void> updatePassword(String newPassword) => _guard(() async {
    await _requireAuth.updateUser(UserAttributes(password: newPassword));
  });

  @override
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      // The local session is cleared even when the server can't be reached.
      debugPrint('[auth] sign-out: $e');
    }
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 20));
    } on AuthFailure {
      rethrow;
    } on TimeoutException {
      throw const AuthFailure('auth_error_network');
    } on AuthRetryableFetchException {
      throw const AuthFailure('auth_error_network');
    } on AuthWeakPasswordException {
      throw const AuthFailure('auth_error_weak_password');
    } on AuthException catch (e) {
      debugPrint('[auth] ${e.code} ${e.statusCode}: ${e.message}');
      throw AuthFailure(errorKeyForCode(e.code));
    } catch (e) {
      // http ClientException / SocketException: no connection.
      debugPrint('[auth] $e');
      throw const AuthFailure('auth_error_network');
    }
  }

  /// Supabase Auth error code -> translation key.
  @visibleForTesting
  static String errorKeyForCode(String? code) => switch (code) {
    'invalid_credentials' => 'auth_error_invalid_credentials',
    'email_not_confirmed' => 'auth_error_email_not_confirmed',
    'user_already_exists' || 'email_exists' => 'auth_error_user_exists',
    'weak_password' => 'auth_error_weak_password',
    'same_password' => 'auth_error_same_password',
    'email_address_invalid' => 'login_validation_email',
    'email_address_not_authorized' => 'auth_error_email_not_authorized',
    'signup_disabled' ||
    'email_provider_disabled' => 'auth_error_signup_disabled',
    'over_email_send_rate_limit' ||
    'over_request_rate_limit' => 'auth_error_rate_limit',
    _ => 'auth_error_unknown',
  };
}
