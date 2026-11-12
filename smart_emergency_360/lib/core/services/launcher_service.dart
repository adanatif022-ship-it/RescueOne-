import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer, SMS composer, email app and Google Maps.
/// Every method reports success/failure instead of throwing. It tries to
/// launch directly rather than relying on canLaunchUrl, which wrongly
/// answers "no" on some Android/iOS setups. Nothing is ever sent or dialled
/// without the user confirming in the opened app.
class LauncherService {
  Future<bool> _launch(Uri uri, {bool external = false}) async {
    try {
      return await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } catch (_) {
      return false;
    }
  }

  static String cleanPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9+*#]'), '');

  Future<bool> callNumber(String phoneNumber) =>
      _launch(Uri(scheme: 'tel', path: cleanPhone(phoneNumber)));

  /// Opens the SMS composer for [phoneNumber], optionally pre-filled with
  /// [body]. The user still has to press Send.
  Future<bool> composeSms(String phoneNumber, {String? body}) {
    final number = cleanPhone(phoneNumber);
    if (body == null || body.isEmpty) {
      return _launch(Uri(scheme: 'sms', path: number));
    }
    final encoded = Uri.encodeComponent(body);
    // iOS expects "&body=", Android (and others) "?body=".
    final separator = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? '&'
        : '?';
    return _launch(Uri.parse('sms:$number${separator}body=$encoded'));
  }

  /// Opens a WhatsApp chat with [phoneNumber] (international format),
  /// optionally with a pre-typed [message]. The user still presses Send.
  Future<bool> openWhatsApp(String phoneNumber, {String? message}) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final text = message == null ? '' : '?text=${Uri.encodeComponent(message)}';
    return _launch(Uri.parse('https://wa.me/$digits$text'), external: true);
  }

  Future<bool> openUrl(String url) => _launch(Uri.parse(url), external: true);

  Future<bool> openEmail(String address, {String? subject}) => _launch(
    Uri(
      scheme: 'mailto',
      path: address,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    ),
  );

  static String mapsLink(double latitude, double longitude) =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  /// Drops a pin on the exact coordinates (a text label would make Google
  /// search by name instead, which can land on a different place).
  Future<bool> openMapsForCoordinates({
    required double latitude,
    required double longitude,
  }) => _launch(Uri.parse(mapsLink(latitude, longitude)), external: true);

  Future<bool> openMapsDirections({
    required double destinationLat,
    required double destinationLng,
  }) => _launch(
    Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
    ),
    external: true,
  );
}
