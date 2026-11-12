# Rescue One

Bilingual (Arabic / English, RTL / LTR) emergency app built with Flutter: SOS
alerts, real nearby hospitals from OpenStreetMap with smart routing, an incident
assistant, trusted contacts, a medical profile, and incident tracking.
Graduation project - it does not replace official emergency services.

See the main README one folder up (Arabic) for features, what is real vs
simulated, and the fixes made from the application report.

## Run

```bash
flutter pub get
flutter run -d chrome          # web
flutter run                    # Android device / emulator
flutter build web --release    # served by ../serve_web.py
flutter build apk --release
flutter analyze && flutter test
```

Requirements: Flutter 3.44+ (Dart 3.12+). Location permission is needed for
nearby hospitals.

## Architecture

```
lib/
  main.dart               entry point, error fallback
  app_dependencies.dart   creates + loads every repository before the first frame
  app.dart                providers, theme (light/dark), locale, notification banners
  core/
    config/      AppConfig: default emergency number, support contacts, radius
    language/    AppLanguage + translations.dart (every user-visible string)
    models/      Incident, Hospital, TrustedContact, EmergencyProfile, SavedPlace,
                 AppNotification, OsmPlace
    services/    ChangeNotifier repositories (auth, settings, contacts, profile,
                 incidents, notifications, hospitals, nearby services, saved places)
                 OsmPlacesService     Overpass race + Nominatim fallback
                 hospital_ranking     smart recommendation (pure functions)
                 PlacesCache          last successful download, shown offline
                 LocationService, LauncherService, StorageService
    theme/       AppColors (neutral colors follow dark mode), AppTheme
    utils/       assistant_nlp (Arabic/English free-text understanding), UI helpers
    widgets/     shared widgets
  screens/       20 screens + the bottom-navigation shell
test/            unit + widget tests (fake location/OSM services, no network)
```

All data stays on the device (`shared_preferences`). The only network calls go
to OpenStreetMap services (Overpass, Nominatim) to find nearby places.
