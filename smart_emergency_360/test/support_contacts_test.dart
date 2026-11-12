import 'package:flutter_test/flutter_test.dart';
import 'package:smart_emergency_360/core/config/app_config.dart';
import 'package:smart_emergency_360/core/services/launcher_service.dart';

void main() {
  test('support phone dials and opens WhatsApp in international format', () {
    expect(LauncherService.cleanPhone(AppConfig.supportPhone), '+60182974348');
    // openWhatsApp keeps digits only: wa.me needs the country code, no "+".
    expect(
      AppConfig.supportPhone.replaceAll(RegExp(r'[^0-9]'), ''),
      '60182974348',
    );
  });

  test('support email is a real address, not the old placeholder', () {
    expect(AppConfig.supportEmail, contains('@'));
    expect(AppConfig.supportEmail, isNot('support@rescueone.app'));
    expect(AppConfig.supportPhone, isNot('920000000'));
  });
}
