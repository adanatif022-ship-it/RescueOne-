import 'package:flutter/foundation.dart';
import '../models/emergency_profile.dart';
import 'storage_service.dart';

class ProfileRepository extends ChangeNotifier {
  static const _key = 'emergency_profile';
  final StorageService _storage;

  ProfileRepository(this._storage);

  EmergencyProfile _profile = const EmergencyProfile();
  EmergencyProfile get profile => _profile;

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is Map) {
      _profile = EmergencyProfile.fromJson(Map<String, dynamic>.from(raw));
      notifyListeners();
    }
  }

  Future<void> saveProfile(EmergencyProfile profile) async {
    _profile = profile;
    notifyListeners();
    await _storage.saveJson(_key, profile.toJson());
  }

  Future<void> clear() async {
    _profile = const EmergencyProfile();
    notifyListeners();
    await _storage.remove(_key);
  }
}
