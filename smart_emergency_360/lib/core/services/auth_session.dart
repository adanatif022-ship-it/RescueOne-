import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_backend.dart';
import 'storage_service.dart';

/// Result of [AuthSession.register].
enum RegisterOutcome { signedIn, confirmEmail }

/// The user's session: a real account (Supabase Auth, see
/// [SupabaseAuthBackend]) or a local guest.
///
/// * Guest mode needs no account and no network, so SOS is never blocked
///   behind a sign-in screen.
/// * Accounts keep their name and phone on the server, so signing in on
///   another device restores them.
/// * The account session is kept by Supabase. "Remember me" off = it is
///   signed out the next time the app starts.
/// * The medical profile, contacts and incidents still stay on the device.
class AuthSession extends ChangeNotifier {
  AuthSession(this._storage, {AuthBackend? backend})
    : _backend = backend ?? SupabaseAuthBackend();

  static const _sessionKey = 'auth_session';

  final StorageService _storage;
  final AuthBackend _backend;
  StreamSubscription<AuthBackendEvent>? _events;

  bool _isSignedIn = false;
  bool _isGuest = false;
  String? _displayName;
  String? _email;
  String? _phone;
  bool _needsNewPassword = false;

  /// Set while signIn/register run: Supabase also reports their result as
  /// a "signed in" event, which must not overwrite the Remember-me choice.
  bool _busy = false;

  bool get isSignedIn => _isSignedIn;
  bool get isGuest => _isGuest;

  /// The name entered at registration, or null - callers show a localized
  /// "Guest" fallback rather than guessing a name.
  String? get realName => _displayName;
  String? get email => _email;
  String? get phone => _phone;

  /// True after the user opened a password-reset link: the app asks for a
  /// new password (see [updatePassword]).
  bool get needsNewPassword => _needsNewPassword;

  Future<void> load() async {
    final saved = await _storage.readJson(_sessionKey);
    final user = _backend.currentUser;
    if (user != null) {
      final remember = !(saved is Map && saved['remember'] == false);
      if (remember) {
        _applyUser(user);
      } else {
        await _backend.signOut();
        await _storage.remove(_sessionKey);
      }
    } else if (saved is Map &&
        saved['signedIn'] == true &&
        saved['guest'] == true) {
      _isSignedIn = true;
      _isGuest = true;
    }
    await _events?.cancel();
    _events = _backend.events.listen(_onBackendEvent);
    notifyListeners();
  }

  void _onBackendEvent(AuthBackendEvent event) {
    switch (event) {
      case AuthBackendEvent.signedIn:
      case AuthBackendEvent.userUpdated:
        final user = _backend.currentUser;
        if (user == null || _busy) return;
        // e.g. the email-confirmation link opened in this browser.
        if (!_isSignedIn || _isGuest) unawaited(_persist(remember: true));
        _applyUser(user);
      case AuthBackendEvent.passwordRecovery:
        final user = _backend.currentUser;
        if (user != null) _applyUser(user);
        _needsNewPassword = true;
      case AuthBackendEvent.signedOut:
        if (_isGuest || !_isSignedIn) return;
        _clear();
        unawaited(_storage.remove(_sessionKey));
    }
    notifyListeners();
  }

  void _applyUser(AuthUserInfo user) {
    _isSignedIn = true;
    _isGuest = false;
    _email = user.email;
    _displayName = user.name;
    _phone = user.phone;
  }

  void _clear() {
    _isSignedIn = false;
    _isGuest = false;
    _displayName = null;
    _email = null;
    _phone = null;
    _needsNewPassword = false;
  }

  /// Returns null on success, otherwise a translation key for the error.
  Future<String?> signIn(
    String email,
    String password, {
    bool remember = true,
  }) async {
    _busy = true;
    try {
      final user = await _backend.signIn(email.trim(), password);
      _applyUser(user);
      notifyListeners();
      await _persist(remember: remember);
      return null;
    } on AuthFailure catch (f) {
      return f.key;
    } finally {
      _busy = false;
    }
  }

  /// Creates a real account. Throws [AuthFailure].
  Future<RegisterOutcome> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    _busy = true;
    try {
      final user = await _backend.signUp(
        email: email.trim(),
        password: password,
        name: fullName.trim(),
        phone: phone.trim(),
      );
      if (user == null) return RegisterOutcome.confirmEmail;
      _applyUser(user);
      notifyListeners();
      await _persist(remember: true);
      return RegisterOutcome.signedIn;
    } finally {
      _busy = false;
    }
  }

  /// Returns null on success, otherwise a translation key for the error.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _backend.sendPasswordReset(email.trim());
      return null;
    } on AuthFailure catch (f) {
      return f.key;
    }
  }

  /// Returns null on success, otherwise a translation key for the error.
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _backend.updatePassword(newPassword);
      _needsNewPassword = false;
      notifyListeners();
      return null;
    } on AuthFailure catch (f) {
      return f.key;
    }
  }

  /// The user closed the new-password prompt without saving.
  void dismissPasswordRecovery() {
    if (!_needsNewPassword) return;
    _needsNewPassword = false;
    notifyListeners();
  }

  Future<void> continueAsGuest({bool remember = true}) async {
    if (_isSignedIn && !_isGuest) await _backend.signOut();
    _clear();
    _isSignedIn = true;
    _isGuest = true;
    notifyListeners();
    if (remember) {
      await _storage.saveJson(_sessionKey, {'signedIn': true, 'guest': true});
    } else {
      await _storage.remove(_sessionKey);
    }
  }

  Future<void> signOut() async {
    final hadAccount = _isSignedIn && !_isGuest;
    _clear();
    notifyListeners();
    await _storage.remove(_sessionKey);
    if (hadAccount) await _backend.signOut();
  }

  /// Settings > Delete all data: signs out on this device. (The account
  /// itself stays on the server.)
  Future<void> reset() => signOut();

  Future<void> _persist({required bool remember}) =>
      _storage.saveJson(_sessionKey, {'signedIn': true, 'remember': remember});

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }
}
