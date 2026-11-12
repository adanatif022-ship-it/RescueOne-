/// App-wide constants that used to be hard-coded inside screens.
///
/// The emergency number shown on the call button is only a *default* -
/// users can change it in Settings (see SettingsRepository.emergencyNumber)
/// to match the country they are in.
class AppConfig {
  AppConfig._();

  /// Default number dialled by "Call emergency services". 999 is the
  /// emergency number in Malaysia (the project's university), the UK and
  /// several other countries. Changeable in Settings.
  static const String defaultEmergencyNumber = '999';

  /// Quick presets offered in Settings. 112 works from most mobile phones
  /// worldwide (GSM standard), 911 across the Americas.
  static const List<String> emergencyNumberPresets = ['999', '112', '911'];

  /// Project support channels (Help & Support screen). These are the
  /// original project's placeholder values - replace them with the real
  /// support line/inbox before publishing the app.
  static const String supportPhone = '920000000';
  static const String supportEmail = 'support@rescueone.app';

  /// Map position used only before the first real GPS fix (never used to
  /// query hospitals). Aden - the city used for testing in the report.
  static const double defaultLatitude = 12.7855;
  static const double defaultLongitude = 45.0187;

  /// Search radius for hospitals and nearby services.
  static const int searchRadiusMeters = 10000;

  /// Honest identification sent to OpenStreetMap services on Android/iOS,
  /// as their usage policies require. (Browsers send their own.)
  static const String userAgent = 'RescueOne/1.1 (Flutter; graduation project)';

  /// Average urban driving speed used to estimate arrival time from the
  /// real distance.
  static const double averageSpeedKmh = 32;

  /// Supabase project used for real user accounts (sign up / sign in).
  /// The publishable key is meant to ship inside apps - it only allows
  /// what the project's Auth settings and database policies permit.
  static const String supabaseUrl = 'https://fwjzoanekqznsrftzzvz.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_9Tn5vKiyt-Db2tNc59cUPg_Pus1S-dT';

  /// Supabase's minimum password length (Auth > Providers > Email).
  static const int minPasswordLength = 6;
}
