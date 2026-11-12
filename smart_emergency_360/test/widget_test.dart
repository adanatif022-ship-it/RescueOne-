import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emergency_360/app.dart';
import 'package:smart_emergency_360/app_dependencies.dart';
import 'package:smart_emergency_360/core/models/osm_place.dart';
import 'package:smart_emergency_360/core/services/auth_backend.dart';
import 'package:smart_emergency_360/core/theme/app_colors.dart';
import 'package:smart_emergency_360/screens/auth/login_screen.dart';
import 'package:smart_emergency_360/screens/root/root_shell.dart';
import 'package:smart_emergency_360/screens/sos/emergency_type_screen.dart';
import 'package:smart_emergency_360/screens/splash/splash_screen.dart';

import 'test_helpers.dart';

/// Phone-sized surface: 360 x 760 logical px, the narrow Android width
/// where the original quick-services cards overflowed.
Future<void> usePhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<AppDependencies> loadApp({
  Map<String, Object> prefs = const {},
  AuthBackend? authBackend,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppDependencies.load(
    authBackend: authBackend,
    location: FakeLocationService(lat: 12.7855, lng: 45.0187),
    placesService: FakeOsmPlacesService(
      places: [
        place(
          'node/1',
          'Al-Jumhuriya Hospital',
          12.80,
          45.03,
          emergency: 'yes',
        ),
        place(
          'node/2',
          'Karama Clinic',
          12.79,
          45.02,
          kind: OsmPlaceKind.clinic,
        ),
      ],
    ),
  );
}

void main() {
  tearDown(() => AppColors.setDark(false));

  testWidgets('first visit opens on the welcome screen, not as a guest', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(prefs: {'app_locale': 'en'}),
    );
    await tester.pumpWidget(RescueOneApp(dependencies: deps!));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(RootShell), findsNothing);
    expect(deps.auth.isGuest, isFalse);
  });

  testWidgets('a signed-in account opens straight on Home', (tester) async {
    await usePhoneSize(tester);
    final backend = FakeAuthBackend();
    final deps = await tester.runAsync(() async {
      await backend.signUp(
        email: 'user@example.com',
        password: 'secret123',
        name: 'Test User',
        phone: '0123456',
      );
      return loadApp(prefs: {'app_locale': 'en'}, authBackend: backend);
    });
    await tester.pumpWidget(RescueOneApp(dependencies: deps!));
    await tester.pumpAndSettle();

    expect(find.byType(RootShell), findsOneWidget);
    expect(find.textContaining('Test User'), findsWidgets);
  });

  testWidgets('welcome screen with SOS can be shown and used', (tester) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(prefs: {'app_locale': 'en'}),
    );
    await tester.pumpWidget(
      RescueOneApp(dependencies: deps!, initialHome: const SplashScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Rescue One'), findsWidgets);
    expect(find.text('Emergency? Send SOS now'), findsOneWidget);

    // SOS works without signing in.
    await tester.tap(find.text('Emergency? Send SOS now'));
    await tester.pumpAndSettle();
    expect(find.byType(EmergencyTypeScreen), findsOneWidget);
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('remembered session opens Home without overflow ($locale)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final deps = await tester.runAsync(
        () => loadApp(
          prefs: {
            'app_locale': locale,
            'auth_session': '{"signedIn":true,"guest":true}',
          },
        ),
      );
      await tester.pumpWidget(RescueOneApp(dependencies: deps!));
      await tester.pumpAndSettle();

      expect(find.byType(RootShell), findsOneWidget);
      // Real (fake-served) hospitals are loaded and recommended.
      expect(
        find.textContaining('Al-Jumhuriya Hospital', skipOffstage: false),
        findsWidgets,
      );
      // Any RenderFlex overflow would have failed the test already.
      expect(tester.takeException(), isNull);

      // Scroll the whole home screen to render every section.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tab screens have a back arrow that returns to Home', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(
        prefs: {
          'app_locale': 'en',
          'auth_session': '{"signedIn":true,"guest":true}',
        },
      ),
    );
    await tester.pumpWidget(RescueOneApp(dependencies: deps!));
    await tester.pumpAndSettle();
    expect(
      find.byType(BackButton),
      findsNothing,
    ); // Home: nothing to go back to

    for (final tab in ['Hospitals', 'Assistant', 'History']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget, reason: tab);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsNothing, reason: tab);
      expect(find.text('Quick emergency services'), findsOneWidget);
    }
  });

  testWidgets('login screen has a back arrow to the welcome screen', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(prefs: {'app_locale': 'en'}),
    );
    await tester.pumpWidget(
      RescueOneApp(dependencies: deps!, initialHome: const SplashScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In').first);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('dark mode switches the whole palette', (tester) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(
        prefs: {
          'app_locale': 'en',
          'auth_session': '{"signedIn":true,"guest":true}',
        },
      ),
    );
    await tester.pumpWidget(RescueOneApp(dependencies: deps!));
    await tester.pumpAndSettle();
    expect(AppColors.isDark, isFalse);

    await deps.settings.setDarkMode(true);
    await tester.pumpAndSettle();
    expect(AppColors.isDark, isTrue);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });

  testWidgets('emergency type grid fits on a narrow phone (Arabic)', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final deps = await tester.runAsync(
      () => loadApp(
        prefs: {
          'app_locale': 'ar',
          'auth_session': '{"signedIn":true,"guest":true}',
        },
      ),
    );
    await tester.pumpWidget(RescueOneApp(dependencies: deps!));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('نداء استغاثة'));
    await tester.pumpAndSettle();
    expect(find.byType(EmergencyTypeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
