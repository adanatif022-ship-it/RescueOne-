import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'picked_contact.dart';

/// Web: the browser Contact Picker API (Chrome on Android). The browser
/// shows its own picker and shares only the contact the user selects.
JSObject? get _contactsManager {
  final navigator = globalContext['navigator'];
  if (navigator == null) return null;
  final nav = navigator as JSObject;
  if (!nav.has('contacts')) return null;
  return nav['contacts'] as JSObject?;
}

bool get isSupported =>
    _contactsManager != null && globalContext.has('ContactsManager');

Future<PickedContact?> pick() async {
  final manager = _contactsManager;
  if (manager == null) return null;
  try {
    final properties = <JSAny>['name'.toJS, 'tel'.toJS].toJS;
    final options = JSObject()..['multiple'] = false.toJS;
    final selected = await manager
        .callMethod<JSPromise<JSArray<JSObject>>>(
          'select'.toJS,
          properties,
          options,
        )
        .toDart;
    final contacts = selected.toDart;
    if (contacts.isEmpty) return null;
    final contact = contacts.first;

    String firstValue(String key) {
      final value = contact[key];
      if (value == null) return '';
      final values = (value as JSArray<JSString>).toDart;
      return values.isEmpty ? '' : values.first.toDart.trim();
    }

    final phone = firstValue('tel');
    if (phone.isEmpty) return null;
    return PickedContact(firstValue('name'), phone);
  } catch (_) {
    return null;
  }
}
