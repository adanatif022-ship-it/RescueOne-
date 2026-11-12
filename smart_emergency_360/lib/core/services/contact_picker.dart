import 'contact_picker_io.dart'
    if (dart.library.js_interop) 'contact_picker_web.dart'
    as platform;
import 'picked_contact.dart';

export 'picked_contact.dart';

/// Picks one contact from the phone's address book:
/// * Android app - the system contact picker (no permission needed);
/// * web - Chrome on Android's Contact Picker;
/// * elsewhere [isSupported] is false and the number is typed manually.
class ContactPickerService {
  bool get isSupported => platform.isSupported;

  /// The chosen contact, or null if the user cancelled or it had no number.
  Future<PickedContact?> pick() => platform.pick();
}
