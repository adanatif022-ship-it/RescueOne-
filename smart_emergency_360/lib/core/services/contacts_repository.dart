import 'package:flutter/foundation.dart';
import '../models/trusted_contact.dart';
import 'storage_service.dart';

class ContactsRepository extends ChangeNotifier {
  static const _key = 'trusted_contacts';
  final StorageService _storage;

  ContactsRepository(this._storage);

  List<TrustedContact> _contacts = [];
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  List<TrustedContact> get notifiedContacts =>
      _contacts.where((c) => c.notifyDuringSos).toList();

  Future<void> load() async {
    final raw = await _storage.readJson(_key);
    if (raw is List) {
      _contacts = raw
          .map((e) => TrustedContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    await _storage.saveJson(_key, _contacts.map((c) => c.toJson()).toList());
  }

  Future<void> addContact(TrustedContact contact) async {
    if (contact.isPrimary) {
      _contacts = _contacts.map((c) => c.copyWith(isPrimary: false)).toList();
    }
    _contacts.add(contact);
    notifyListeners();
    await _persist();
  }

  Future<void> updateContact(TrustedContact updated) async {
    if (updated.isPrimary) {
      _contacts = _contacts
          .map((c) => c.copyWith(isPrimary: c.id == updated.id))
          .toList();
    }
    final index = _contacts.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _contacts[index] = updated;
      notifyListeners();
      await _persist();
    }
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> setPrimary(String id) async {
    _contacts = _contacts
        .map((c) => c.copyWith(isPrimary: c.id == id))
        .toList();
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _contacts = [];
    notifyListeners();
    await _storage.remove(_key);
  }
}
