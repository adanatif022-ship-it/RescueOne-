import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

/// App-level preferences - every one of them changes real behaviour:
/// * [darkMode] switches the whole app to the dark palette.
/// * [notificationsEnabled] shows/hides in-app alerts and the bell badge
///   when an incident changes status.
/// * [silentModeDefault] pre-selects Silent SOS on the SOS screen.
/// * [locationAlwaysOn] = detect location at launch; off = only when the
///   user opens SOS or asks for hospitals.
/// * [emergencyNumber] is the number dialled by "Call emergency services".
class SettingsRepository extends ChangeNotifier {
  SettingsRepository(this._storage);

  static const _key = 'app_settings';
  final StorageService _storage;

  bool _silentModeDefault = false;
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _locationAlwaysOn = true;
  String _emergencyNumber = AppConfig.defaultEmergencyNumber;

  bool get silentModeDefault => _silentModeDefault;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationAlwaysOn => _locationAlwaysOn;
  String get emergencyNumber => _emergencyNumber;

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is Map) {
      _silentModeDefault = raw['silentModeDefault'] as bool? ?? false;
      // 'darkModePrototype' is the key used by the first version.
      _darkMode =
          raw['darkMode'] as bool? ??
          raw['darkModePrototype'] as bool? ??
          false;
      _notificationsEnabled = raw['notificationsEnabled'] as bool? ?? true;
      _locationAlwaysOn = raw['locationAlwaysOn'] as bool? ?? true;
      final number = raw['emergencyNumber'] as String?;
      if (number != null && isValidEmergencyNumber(number)) {
        _emergencyNumber = number;
      }
      notifyListeners();
    }
  }

  Future<void> _persist() => _storage.saveJson(_key, {
    'silentModeDefault': _silentModeDefault,
    'darkMode': _darkMode,
    'notificationsEnabled': _notificationsEnabled,
    'locationAlwaysOn': _locationAlwaysOn,
    'emergencyNumber': _emergencyNumber,
  });

  Future<void> setSilentModeDefault(bool value) async {
    _silentModeDefault = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLocationAlwaysOn(bool value) async {
    _locationAlwaysOn = value;
    notifyListeners();
    await _persist();
  }

  static bool isValidEmergencyNumber(String value) =>
      RegExp(r'^[0-9]{2,6}$').hasMatch(value.trim());

  /// Returns false (and changes nothing) for an invalid number.
  Future<bool> setEmergencyNumber(String value) async {
    final number = value.trim();
    if (!isValidEmergencyNumber(number)) return false;
    _emergencyNumber = number;
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> reset() async {
    _silentModeDefault = false;
    _darkMode = false;
    _notificationsEnabled = true;
    _locationAlwaysOn = true;
    _emergencyNumber = AppConfig.defaultEmergencyNumber;
    notifyListeners();
    await _storage.remove(_key);
  }
}
