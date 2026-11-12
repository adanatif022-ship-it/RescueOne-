import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON persistence wrapper around shared_preferences.
/// This app has no backend - all data (contacts, profile, incidents,
/// settings, cached hospitals) is stored locally on-device only.
class StorageService {
  Future<void> saveJson(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<dynamic> readJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Wipes every value this app stored (Settings > Delete all data).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
