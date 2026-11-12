import 'package:flutter/foundation.dart';

import 'core/language/app_language.dart';
import 'core/services/auth_backend.dart';
import 'core/services/auth_session.dart';
import 'core/services/contacts_repository.dart';
import 'core/services/hospital_repository.dart';
import 'core/services/incident_repository.dart';
import 'core/services/location_service.dart';
import 'core/services/nearby_services_repository.dart';
import 'core/services/notifications_repository.dart';
import 'core/services/osm_places_service.dart';
import 'core/services/profile_repository.dart';
import 'core/services/saved_places_repository.dart';
import 'core/services/settings_repository.dart';
import 'core/services/storage_service.dart';

/// Every app-wide repository, created and loaded from device storage
/// before the first frame (so the saved language, theme and session are
/// applied immediately - no flash of the wrong screen).
class AppDependencies {
  final StorageService storage;
  final LocationService location;
  final AppLanguage language;
  final AuthSession auth;
  final SettingsRepository settings;
  final ContactsRepository contacts;
  final ProfileRepository profile;
  final NotificationsRepository notifications;
  final IncidentRepository incidents;
  final HospitalRepository hospitals;
  final NearbyServicesRepository nearby;
  final SavedPlacesRepository savedPlaces;

  AppDependencies._({
    required this.storage,
    required this.location,
    required this.language,
    required this.auth,
    required this.settings,
    required this.contacts,
    required this.profile,
    required this.notifications,
    required this.incidents,
    required this.hospitals,
    required this.nearby,
    required this.savedPlaces,
  });

  /// [location], [placesService] and [authBackend] can be replaced in tests.
  static Future<AppDependencies> load({
    LocationService? location,
    OsmPlacesService? placesService,
    AuthBackend? authBackend,
  }) async {
    final storage = StorageService();
    final locationService = location ?? LocationService();
    final places = placesService ?? OsmPlacesService();
    final notifications = NotificationsRepository(storage);
    final deps = AppDependencies._(
      storage: storage,
      location: locationService,
      language: AppLanguage(),
      auth: AuthSession(storage, backend: authBackend),
      settings: SettingsRepository(storage),
      contacts: ContactsRepository(storage),
      profile: ProfileRepository(storage),
      notifications: notifications,
      incidents: IncidentRepository(storage, notifications: notifications),
      hospitals: HospitalRepository(
        locationService,
        placesService: places,
        storage: storage,
      ),
      nearby: NearbyServicesRepository(placesService: places, storage: storage),
      savedPlaces: SavedPlacesRepository(storage),
    );

    // A corrupted value must never stop the app from opening.
    Future<void> safe(Future<void> Function() load) async {
      try {
        await load();
      } catch (e) {
        debugPrint('[startup] load failed: $e');
      }
    }

    await Future.wait([
      safe(deps.language.load),
      safe(deps.auth.load),
      safe(deps.settings.load),
      safe(deps.contacts.load),
      safe(deps.profile.load),
      safe(deps.notifications.load),
      safe(deps.savedPlaces.load),
      safe(deps.hospitals.loadCache),
      safe(deps.nearby.loadCache),
    ]);
    await safe(deps.incidents.load);
    return deps;
  }

  /// Settings > Delete all data: wipes storage and resets every
  /// repository in memory. The chosen language is kept.
  Future<void> deleteAllData() async {
    final keepArabic = language.isArabic;
    await incidents.clear();
    await notifications.clear();
    await contacts.clear();
    await profile.clear();
    await savedPlaces.clear();
    await hospitals.clearSavedData();
    await nearby.clearSavedData();
    await settings.reset();
    await auth.reset();
    await storage.clearAll();
    await language.setLocale(keepArabic ? AppLocale.ar : AppLocale.en);
    await language.persist();
  }
}
