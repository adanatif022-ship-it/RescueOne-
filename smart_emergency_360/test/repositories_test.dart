import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emergency_360/core/models/incident.dart';
import 'package:smart_emergency_360/core/models/osm_place.dart';
import 'package:smart_emergency_360/core/language/app_language.dart';
import 'package:smart_emergency_360/core/language/translations.dart';
import 'package:smart_emergency_360/core/services/auth_backend.dart';
import 'package:smart_emergency_360/core/services/auth_session.dart';
import 'package:smart_emergency_360/core/services/hospital_repository.dart';
import 'package:smart_emergency_360/core/services/incident_repository.dart';
import 'package:smart_emergency_360/core/services/notifications_repository.dart';
import 'package:smart_emergency_360/core/services/settings_repository.dart';
import 'package:smart_emergency_360/core/services/storage_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('IncidentRepository', () {
    test('creates readable ids, records times and notifications', () async {
      final storage = StorageService();
      final notifications = NotificationsRepository(storage);
      final repo = IncidentRepository(
        storage,
        notifications: notifications,
        stepInterval: const Duration(hours: 1), // no auto-progress here
      );

      final a = await repo.createIncident(
        type: IncidentType.fire,
        description: 'kitchen',
        mode: AlertMode.silent,
        location: const IncidentLocation(latitude: 1, longitude: 2),
        recommendedHospital: hospital('h1', distanceKm: 1.2),
      );
      final b = await repo.createIncident(
        type: IncidentType.medical,
        description: '',
        mode: AlertMode.normal,
        location: null,
      );
      final year = DateTime.now().year;
      expect(a.id, 'INC-$year-001');
      expect(b.id, 'INC-$year-002');
      expect(a.hospital!.id, 'h1');
      expect(a.statusTimes.keys, [IncidentStatus.created]);
      expect(repo.activeIncident!.id, b.id); // newest open incident

      await repo.advanceToNextStage(a.id);
      expect(repo.byId(a.id)!.status, IncidentStatus.sent);
      expect(repo.byId(a.id)!.statusTimes, contains(IncidentStatus.sent));

      await repo.cancelIncident(b.id);
      expect(repo.byId(b.id)!.status, IncidentStatus.cancelled);
      // Cancelled incidents stay off the linear timeline.
      await repo.advanceToNextStage(b.id);
      expect(repo.byId(b.id)!.status, IncidentStatus.cancelled);

      await repo.rateIncident(a.id, 5, ' great ');
      expect(repo.byId(a.id)!.rating, 5);
      expect(repo.byId(a.id)!.feedback, 'great');

      // created x2, sent, cancelled
      expect(notifications.items.length, 4);
      expect(notifications.unreadCount, 4);
      await notifications.markAllRead();
      expect(notifications.unreadCount, 0);

      // Everything survives a restart.
      final reloaded = IncidentRepository(
        storage,
        stepInterval: const Duration(hours: 1),
      );
      await reloaded.load();
      final restored = reloaded.byId(a.id)!;
      expect(restored.status, IncidentStatus.sent);
      expect(restored.mode, AlertMode.silent);
      expect(restored.hospital!.distanceKm, 1.2);
      expect(restored.rating, 5);
      repo.dispose();
      reloaded.dispose();
    });

    test('auto-progress stops at "help on the way"', () async {
      final repo = IncidentRepository(
        StorageService(),
        stepInterval: const Duration(milliseconds: 5),
      );
      final incident = await repo.createIncident(
        type: IncidentType.accident,
        description: '',
        mode: AlertMode.normal,
        location: null,
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(repo.byId(incident.id)!.status, IncidentStatus.helpOnWay);
      repo.dispose();
    });
  });

  test('a finished incident can be deleted with its notifications', () async {
    final storage = StorageService();
    final notifications = NotificationsRepository(storage);
    final repo = IncidentRepository(
      storage,
      notifications: notifications,
      stepInterval: const Duration(hours: 1),
    );
    final open = await repo.createIncident(
      type: IncidentType.fire,
      description: '',
      mode: AlertMode.normal,
      location: null,
    );
    await repo.deleteIncident(open.id); // open incidents are protected
    expect(repo.byId(open.id), isNotNull);

    await repo.cancelIncident(open.id);
    await repo.deleteIncident(open.id);
    expect(repo.byId(open.id), isNull);
    expect(notifications.items.where((n) => n.incidentId == open.id), isEmpty);
    repo.dispose();
  });

  group('AuthSession (real accounts)', () {
    test('register then sign in restores the account name', () async {
      final storage = StorageService();
      final backend = FakeAuthBackend();
      final auth = AuthSession(storage, backend: backend);
      final outcome = await auth.register(
        'Test User',
        'user@example.com',
        '+60123456789',
        'secret123',
      );
      expect(outcome, RegisterOutcome.signedIn);
      await auth.signOut();
      expect(auth.isSignedIn, isFalse);
      expect(backend.signOutCalls, 1);

      final error = await auth.signIn('USER@example.com', 'secret123');
      expect(error, isNull);
      expect(auth.realName, 'Test User');
      expect(auth.phone, '+60123456789');

      final reopened = AuthSession(storage, backend: backend);
      await reopened.load();
      expect(reopened.isSignedIn, isTrue);
      expect(reopened.isGuest, isFalse);
      expect(reopened.realName, 'Test User');
    });

    test('wrong password is refused with a clear error', () async {
      final backend = FakeAuthBackend();
      final auth = AuthSession(StorageService(), backend: backend);
      await auth.register('A', 'a@b.co', '0123456', 'secret123');
      await auth.signOut();
      expect(
        await auth.signIn('a@b.co', 'wrong-pass'),
        'auth_error_invalid_credentials',
      );
      expect(auth.isSignedIn, isFalse);
    });

    test('without remember me the account is signed out on restart', () async {
      final storage = StorageService();
      final backend = FakeAuthBackend();
      final auth = AuthSession(storage, backend: backend);
      await auth.register('A', 'a@b.co', '0123456', 'secret123');
      await auth.signOut();
      await auth.signIn('a@b.co', 'secret123', remember: false);
      expect(auth.isSignedIn, isTrue);

      final reopened = AuthSession(storage, backend: backend);
      await reopened.load();
      expect(reopened.isSignedIn, isFalse);
      expect(backend.currentUser, isNull);
    });

    test(
      'email confirmation: no session until the email is confirmed',
      () async {
        final backend = FakeAuthBackend(requireEmailConfirmation: true);
        final auth = AuthSession(StorageService(), backend: backend);
        final outcome = await auth.register(
          'A',
          'a@b.co',
          '0123456',
          'secret1',
        );
        expect(outcome, RegisterOutcome.confirmEmail);
        expect(auth.isSignedIn, isFalse);
        expect(
          await auth.signIn('a@b.co', 'secret1'),
          'auth_error_email_not_confirmed',
        );
        backend.confirmEmail('a@b.co');
        expect(await auth.signIn('a@b.co', 'secret1'), isNull);
      },
    );

    test('registering an existing email fails', () async {
      final backend = FakeAuthBackend();
      final auth = AuthSession(StorageService(), backend: backend);
      await auth.register('A', 'a@b.co', '0123456', 'secret1');
      expect(
        () => auth.register('B', 'A@b.co', '0123456', 'secret2'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.key,
            'key',
            'auth_error_user_exists',
          ),
        ),
      );
    });

    test('guest mode needs no account and survives a restart', () async {
      final storage = StorageService();
      final backend = FakeAuthBackend();
      await AuthSession(storage, backend: backend).continueAsGuest();
      final reopened = AuthSession(storage, backend: backend);
      await reopened.load();
      expect(reopened.isSignedIn, isTrue);
      expect(reopened.isGuest, isTrue);
      expect(reopened.email, isNull);
    });

    test('a password-reset link asks for a new password', () async {
      final backend = FakeAuthBackend();
      final auth = AuthSession(StorageService(), backend: backend);
      await auth.load();
      expect(await auth.sendPasswordReset(' a@b.co '), isNull);
      expect(backend.lastResetEmail, 'a@b.co');

      backend.emit(
        AuthBackendEvent.passwordRecovery,
        user: const AuthUserInfo(email: 'a@b.co', name: 'A'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(auth.needsNewPassword, isTrue);
      expect(auth.isSignedIn, isTrue);

      expect(await auth.updatePassword('newSecret1'), isNull);
      expect(backend.lastNewPassword, 'newSecret1');
      expect(auth.needsNewPassword, isFalse);
    });

    test('a session ended by the server signs the account out', () async {
      final backend = FakeAuthBackend();
      final auth = AuthSession(StorageService(), backend: backend);
      await auth.load();
      await auth.register('A', 'a@b.co', '0123456', 'secret1');
      backend.emit(AuthBackendEvent.signedOut);
      await Future<void>.delayed(Duration.zero);
      expect(auth.isSignedIn, isFalse);
    });

    test('Supabase error codes map to messages', () {
      expect(
        SupabaseAuthBackend.errorKeyForCode('invalid_credentials'),
        'auth_error_invalid_credentials',
      );
      expect(
        SupabaseAuthBackend.errorKeyForCode('email_address_not_authorized'),
        'auth_error_email_not_authorized',
      );
      expect(
        SupabaseAuthBackend.errorKeyForCode('over_email_send_rate_limit'),
        'auth_error_rate_limit',
      );
      expect(SupabaseAuthBackend.errorKeyForCode(null), 'auth_error_unknown');
    });

    test('every account message has Arabic and English text', () {
      for (final key in [
        'auth_error_invalid_credentials',
        'auth_error_email_not_confirmed',
        'auth_error_user_exists',
        'auth_error_weak_password',
        'auth_error_same_password',
        'auth_error_email_not_authorized',
        'auth_error_signup_disabled',
        'auth_error_rate_limit',
        'auth_error_network',
        'auth_error_unavailable',
        'auth_error_unknown',
        'login_validation_email',
      ]) {
        expect(translations[key]?[AppLocale.ar], isNotEmpty, reason: key);
        expect(translations[key]?[AppLocale.en], isNotEmpty, reason: key);
      }
    });
  });

  test('SettingsRepository validates the emergency number', () async {
    final settings = SettingsRepository(StorageService());
    expect(settings.emergencyNumber, '999');
    expect(await settings.setEmergencyNumber('12a'), isFalse);
    expect(await settings.setEmergencyNumber('112'), isTrue);
    await settings.setDarkMode(true);

    final reloaded = SettingsRepository(StorageService());
    await reloaded.load();
    expect(reloaded.emergencyNumber, '112');
    expect(reloaded.darkMode, isTrue);
  });

  group('HospitalRepository', () {
    test('keeps the saved list when the network fails', () async {
      final storage = StorageService();
      final location = FakeLocationService(lat: 12.7855, lng: 45.0187);
      final osm = FakeOsmPlacesService(
        places: [
          place(
            'node/1',
            'Near clinic',
            12.789,
            45.019,
            kind: OsmPlaceKind.clinic,
          ),
          place('node/2', 'Hospital', 12.80, 45.03, emergency: 'yes'),
        ],
      );
      final repo = HospitalRepository(
        location,
        placesService: osm,
        storage: storage,
      );
      await repo.refresh();
      expect(repo.hospitals.length, 2);
      expect(repo.hospitals.first.id, 'node/1'); // sorted by distance
      // Medical case: the full hospital with an ER beats the closer clinic.
      expect(repo.recommendationFor(IncidentType.medical)!.id, 'node/2');
      await Future<void>.delayed(Duration.zero); // let the cache save

      // Next launch, offline.
      final offline = HospitalRepository(
        location,
        placesService: FakeOsmPlacesService(errorKey: 'timeout'),
        storage: storage,
      );
      await offline.loadCache();
      expect(offline.hospitals.length, 2);
      expect(offline.usingSavedData, isTrue);
      await offline.refresh(force: true);
      expect(offline.hospitals.length, 2);
      expect(offline.overpassErrorKey, 'timeout');
      expect(offline.usingSavedData, isTrue);
    });

    test('reports a location error without inventing data', () async {
      final repo = HospitalRepository(
        FakeLocationService(errorKey: 'permission_denied'),
        placesService: FakeOsmPlacesService(),
      );
      await repo.refresh();
      expect(repo.hospitals, isEmpty);
      expect(repo.locationErrorKey, 'permission_denied');
      expect(repo.topRecommendation, isNull);
    });
  });
}
