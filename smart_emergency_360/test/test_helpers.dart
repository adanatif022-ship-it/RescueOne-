import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_emergency_360/core/models/hospital.dart';
import 'package:smart_emergency_360/core/services/auth_backend.dart';
import 'package:smart_emergency_360/core/models/osm_place.dart';
import 'package:smart_emergency_360/core/services/location_service.dart';
import 'package:smart_emergency_360/core/services/osm_places_service.dart';

/// Location service that answers instantly without touching GPS.
class FakeLocationService extends LocationService {
  FakeLocationService({
    this.lat,
    this.lng,
    this.errorKey = 'permission_denied',
  });

  double? lat;
  double? lng;
  String errorKey;
  int calls = 0;

  @override
  Future<LocationResult> getCurrentLocation() async {
    calls++;
    if (lat != null && lng != null) return LocationResult.success(lat, lng);
    return LocationResult.failure(errorKey);
  }
}

/// OSM service returning canned results (no network, no timers).
class FakeOsmPlacesService extends OsmPlacesService {
  FakeOsmPlacesService({this.places = const [], this.errorKey})
    : super(client: MockClient((_) async => http.Response('', 500)));

  List<OsmPlace> places;
  String? errorKey;
  int calls = 0;

  @override
  Future<OsmFetchResult> fetch({
    required double lat,
    required double lng,
    required Set<OsmPlaceKind> kinds,
    int radiusMeters = 10000,
  }) async {
    calls++;
    if (errorKey != null) return OsmFetchResult.failure(errorKey);
    return OsmFetchResult.success(
      places.where((p) => kinds.contains(p.kind)).toList(),
      'fake',
    );
  }
}

OsmPlace place(
  String id,
  String name,
  double lat,
  double lng, {
  OsmPlaceKind kind = OsmPlaceKind.hospital,
  String? emergency,
}) => OsmPlace(
  id: id,
  kind: kind,
  name: name,
  latitude: lat,
  longitude: lng,
  emergencyTag: emergency,
);

Hospital hospital(
  String id, {
  double distanceKm = 1,
  int travel = 4,
  int wait = 30,
  HospitalCategory category = HospitalCategory.hospital,
  bool? er,
  CongestionLevel congestion = CongestionLevel.moderate,
}) => Hospital(
  id: id,
  nameEn: id,
  nameAr: id,
  latitude: 0,
  longitude: 0,
  distanceKm: distanceKm,
  travelTimeMinutes: travel,
  congestion: congestion,
  estimatedWaitMinutes: wait,
  category: category,
  hasEmergencyDepartment: er,
);

/// In-memory accounts instead of Supabase (no network).
class FakeAuthBackend implements AuthBackend {
  FakeAuthBackend({this.requireEmailConfirmation = false});

  bool requireEmailConfirmation;
  final _accounts = <String, ({String password, String name, String phone})>{};
  final _confirmed = <String>{};
  final _events = StreamController<AuthBackendEvent>.broadcast();
  AuthUserInfo? _current;
  int signOutCalls = 0;
  String? lastResetEmail;
  String? lastNewPassword;

  /// Simulates a server event (email link opened, session revoked...).
  void emit(AuthBackendEvent event, {AuthUserInfo? user}) {
    if (user != null) _current = user;
    if (event == AuthBackendEvent.signedOut) _current = null;
    _events.add(event);
  }

  @override
  AuthUserInfo? get currentUser => _current;

  @override
  Stream<AuthBackendEvent> get events => _events.stream;

  AuthUserInfo _info(String email) {
    final a = _accounts[email]!;
    return AuthUserInfo(email: email, name: a.name, phone: a.phone);
  }

  @override
  Future<AuthUserInfo> signIn(String email, String password) async {
    final key = email.toLowerCase();
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw const AuthFailure('auth_error_invalid_credentials');
    }
    if (!_confirmed.contains(key)) {
      throw const AuthFailure('auth_error_email_not_confirmed');
    }
    return _current = _info(key);
  }

  @override
  Future<AuthUserInfo?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthFailure('auth_error_user_exists');
    }
    if (password.length < 6) {
      throw const AuthFailure('auth_error_weak_password');
    }
    _accounts[key] = (password: password, name: name, phone: phone);
    if (requireEmailConfirmation) return null;
    _confirmed.add(key);
    return _current = _info(key);
  }

  void confirmEmail(String email) => _confirmed.add(email.toLowerCase());

  @override
  Future<void> sendPasswordReset(String email) async => lastResetEmail = email;

  @override
  Future<void> updatePassword(String newPassword) async {
    if (_current == null) throw const AuthFailure('auth_error_unknown');
    lastNewPassword = newPassword;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _current = null;
  }
}
