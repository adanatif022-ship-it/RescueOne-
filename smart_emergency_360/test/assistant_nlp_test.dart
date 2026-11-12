import 'package:flutter_test/flutter_test.dart';
import 'package:smart_emergency_360/core/models/incident.dart';
import 'package:smart_emergency_360/core/utils/assistant_nlp.dart';

void main() {
  group('classifyIncidentText', () {
    test('understands free Arabic text (the report example)', () {
      expect(classifyIncidentText('حريق كبير'), IncidentType.fire);
      expect(classifyIncidentText('في دخان كثيف بالمطبخ'), IncidentType.fire);
      expect(
        classifyIncidentText('حادث سيارة على الطريق'),
        IncidentType.accident,
      );
      expect(classifyIncidentText('بالسيارة اصطدمنا'), IncidentType.accident);
      expect(classifyIncidentText('شخص ينزف بشدة'), IncidentType.medical);
      expect(
        classifyIncidentText('سقوط شخص وإصابة في الرأس'),
        IncidentType.medical,
      );
      expect(classifyIncidentText('سرقة في المحل'), IncidentType.security);
      expect(
        classifyIncidentText('شخص يلاحقني في الشارع'),
        IncidentType.danger,
      );
    });

    test('understands free English text', () {
      expect(classifyIncidentText('fire'), IncidentType.fire);
      expect(classifyIncidentText('The house is burning'), IncidentType.fire);
      expect(classifyIncidentText('car crash'), IncidentType.accident);
      expect(
        classifyIncidentText('my father has chest pain'),
        IncidentType.medical,
      );
      expect(
        classifyIncidentText('robbery at the shop'),
        IncidentType.security,
      );
      expect(
        classifyIncidentText('someone is following me'),
        IncidentType.danger,
      );
    });

    test('ignores diacritics and letter variants', () {
      expect(classifyIncidentText('حَرِيقٌ'), IncidentType.fire);
      expect(classifyIncidentText('إصابة'), IncidentType.medical);
    });

    test('more specific type wins when several match', () {
      expect(
        classifyIncidentText('car accident and he is bleeding'),
        IncidentType.accident,
      );
    });

    test('returns null when nothing matches', () {
      expect(classifyIncidentText('hello there'), isNull);
      expect(classifyIncidentText(''), isNull);
    });
  });

  test('mentionsCriticalSigns', () {
    expect(mentionsCriticalSigns('he is unconscious'), isTrue);
    expect(mentionsCriticalSigns('لا يتنفس'), isTrue);
    expect(mentionsCriticalSigns('نزيف حاد'), isTrue);
    expect(mentionsCriticalSigns('small cut on finger'), isFalse);
  });

  test('parseYesNo', () {
    expect(parseYesNo('نعم'), isTrue);
    expect(parseYesNo('Yes'), isTrue);
    expect(parseYesNo('ايوه'), isTrue);
    expect(parseYesNo('لا'), isFalse);
    expect(parseYesNo('no'), isFalse);
    expect(parseYesNo('maybe later'), isNull);
  });

  test('parseInjuredCount', () {
    expect(parseInjuredCount('2'), 2);
    expect(parseInjuredCount('٣'), 3); // Arabic-Indic digit
    expect(parseInjuredCount('3+'), 3);
    expect(parseInjuredCount('10'), 3);
    expect(parseInjuredCount('لا أحد'), 0);
    expect(parseInjuredCount('none'), 0);
    expect(parseInjuredCount('شخص واحد'), 1);
    expect(parseInjuredCount('someone'), isNull);
    expect(injuredLabel(3), '3+');
  });

  test('urgency follows the report rules plus critical signs', () {
    String u(
      IncidentType t, {
      bool? conscious = true,
      int injured = 0,
      bool critical = false,
    }) => urgencyKeyFor(
      type: t,
      conscious: conscious,
      injured: injured,
      criticalSigns: critical,
    );
    expect(u(IncidentType.fire), 'assistant_urgency_high');
    expect(u(IncidentType.medical), 'assistant_urgency_high');
    expect(u(IncidentType.security), 'assistant_urgency_medium');
    expect(u(IncidentType.other), 'assistant_urgency_medium');
    expect(u(IncidentType.other, conscious: false), 'assistant_urgency_high');
    expect(u(IncidentType.other, injured: 1), 'assistant_urgency_high');
    expect(u(IncidentType.security, critical: true), 'assistant_urgency_high');
  });
}
