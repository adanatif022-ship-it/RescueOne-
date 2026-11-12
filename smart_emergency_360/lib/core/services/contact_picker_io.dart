import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'picked_contact.dart';

/// Android: opens the system contact picker through a small native channel
/// in MainActivity.kt. The picker gives access only to the one contact the
/// user taps - no contacts permission is requested.
const _channel = MethodChannel('rescue_one/contacts');

bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

Future<PickedContact?> pick() async {
  if (!isSupported) return null;
  try {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pickContact',
    );
    if (result == null) return null;
    final phone = (result['phone'] as String?)?.trim() ?? '';
    if (phone.isEmpty) return null;
    return PickedContact((result['name'] as String?)?.trim() ?? '', phone);
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}
