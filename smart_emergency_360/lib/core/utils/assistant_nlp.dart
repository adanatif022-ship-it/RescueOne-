import '../models/incident.dart';

/// Rule-based understanding of free text typed into the incident
/// assistant (Arabic and English). No external AI service or API key.
///
/// The first version only matched the exact text of the quick-reply
/// buttons, so typing "حريق كبير" or "fire" was classified as "Other" and
/// the urgency dropped to Medium. These helpers fix that.

const _arabicDiacritics = r'[ً-ْٰـ]';

/// Lower-cases, removes Arabic diacritics/tatweel, unifies letter forms
/// (أ إ آ ٱ → ا, ة → ه, ى → ي, ؤ → و, ئ → ي) and converts Arabic-Indic
/// digits to ASCII so "٣" == "3".
String normalizeText(String input) {
  var s = input.toLowerCase().replaceAll(RegExp(_arabicDiacritics), '');
  const map = {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا', 'ة': 'ه', 'ى': 'ي', //
    'ؤ': 'و', 'ئ': 'ي', '٠': '0', '١': '1', '٢': '2', '٣': '3', //
    '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9', //
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', //
    '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch);
  }
  s = buffer.toString();
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<String> _tokens(String normalized) => normalized
    .split(RegExp(r'[^a-z0-9ء-ي+]+'))
    .where((t) => t.isNotEmpty)
    .toList();

/// Arabic words take attached prefixes (و ف ب ل ك + ال); generate the
/// bare forms so "والحريق" or "بالسيارة" still match "حريق"/"سياره".
Iterable<String> _variants(String token) sync* {
  yield token;
  const prefixes = ['وال', 'بال', 'فال', 'كال', 'لل', 'ال', 'و', 'ف', 'ب', 'ل'];
  for (final p in prefixes) {
    if (token.length > p.length + 1 && token.startsWith(p)) {
      yield token.substring(p.length);
    }
  }
}

bool _matches(String normalized, List<String> tokens, List<String> keywords) {
  for (final raw in keywords) {
    final keyword = normalizeText(raw);
    if (keyword.contains(' ')) {
      if (normalized.contains(keyword)) return true;
      continue;
    }
    for (final token in tokens) {
      for (final v in _variants(token)) {
        if (v == keyword) return true;
        // Stems: "burning" ~ "burn", "ينزف" handled as its own keyword.
        if (keyword.length >= 4 && v.startsWith(keyword)) return true;
      }
    }
  }
  return false;
}

const _fireWords = [
  'fire',
  'smoke',
  'burning',
  'flames',
  'flame',
  'blaze',
  'explosion',
  'gas leak',
  'حريق',
  'حرايق',
  'نار',
  'دخان',
  'اشتعال',
  'مشتعل',
  'يحترق',
  'تحترق',
  'لهب',
  'انفجار',
  'تسرب غاز',
  'ولعت',
];
const _accidentWords = [
  'accident',
  'crash',
  'collision',
  'car',
  'vehicle',
  'traffic',
  'run over',
  'hit by',
  'motorcycle',
  'truck',
  'حادث',
  'حادثه',
  'تصادم',
  'اصطدام',
  'سياره',
  'مرور',
  'مروري',
  'دهس',
  'انقلاب',
  'دراجه',
  'شاحنه',
];
const _dangerWords = [
  'following me',
  'followed',
  'stalking',
  'stalker',
  'threat',
  'threaten',
  'kidnap',
  'harass',
  'abuse',
  'violence',
  'unsafe',
  'scared',
  'afraid',
  'danger',
  'attacked me',
  'يلاحقني',
  'يتبعني',
  'يطاردني',
  'تهديد',
  'يهددني',
  'خطف',
  'اختطاف',
  'تحرش',
  'مطارده',
  'عنف',
  'خطر',
  'خايف',
  'خائف',
  'اعتداء',
];
const _securityWords = [
  'theft',
  'thief',
  'steal',
  'stolen',
  'robbery',
  'robbed',
  'burglar',
  'break-in',
  'break in',
  'shooting',
  'gun',
  'gunfire',
  'weapon',
  'fight',
  'riot',
  'suspicious',
  'vandal',
  'police',
  'سرقه',
  'سارق',
  'لص',
  'سطو',
  'اقتحام',
  'اطلاق نار',
  'رصاص',
  'مسلح',
  'سلاح',
  'مشاجره',
  'شجار',
  'هوشه',
  'مشبوه',
  'شرطه',
  'نهب',
];
const _medicalWords = [
  'injury',
  'injured',
  'hurt',
  'bleeding',
  'blood',
  'unconscious',
  'faint',
  'breath',
  'breathing',
  'heart',
  'chest pain',
  'stroke',
  'seizure',
  'diabetic',
  'pregnant',
  'labor',
  'sick',
  'pain',
  'choking',
  'allergic',
  'allergy',
  'poison',
  'overdose',
  'fracture',
  'broken',
  'medical',
  'ambulance',
  'fever',
  'fell',
  'fall',
  'نزيف',
  'ينزف',
  'دم',
  'اغماء',
  'مغمي',
  'مغشي',
  'اغمي',
  'وعي',
  'وعيه',
  'تنفس',
  'يتنفس',
  'قلب',
  'قلبيه',
  'جلطه',
  'سكته',
  'صرع',
  'تشنج',
  'سكري',
  'حامل',
  'ولاده',
  'مريض',
  'الم',
  'وجع',
  'اختناق',
  'غصه',
  'حساسيه',
  'تسمم',
  'كسر',
  'اسعاف',
  'حراره',
  'حمي',
  'اصابه',
  'مصاب',
  'جرح',
  'جروح',
  'سقط',
  'سقوط',
  'طبي',
  'طبيه',
];
const _criticalWords = [
  'unconscious',
  'not breathing',
  "can't breathe",
  'cannot breathe',
  'heavy bleeding',
  'severe bleeding',
  'heart attack',
  'stroke',
  'seizure',
  'choking',
  'overdose',
  'not responding',
  'unresponsive',
  'فاقد الوعي',
  'فقد وعيه',
  'فقدت وعيها',
  'مغمي عليه',
  'مغمي عليها',
  'اغماء',
  'لا يتنفس',
  'ما يتنفس',
  'صعوبه تنفس',
  'صعوبه في التنفس',
  'ضيق تنفس',
  'نزيف حاد',
  'نزيف شديد',
  'نزيف قوي',
  'ازمه قلبيه',
  'جلطه',
  'سكته',
  'تشنج',
  'اختناق',
  'لا يستجيب',
  'ما يرد',
];

/// Best-guess incident type for free text, or null when nothing matches.
/// When several categories match, the more specific one wins
/// (e.g. "car accident, he is bleeding" → accident).
IncidentType? classifyIncidentText(String text) {
  final normalized = normalizeText(text);
  if (normalized.isEmpty) return null;
  final tokens = _tokens(normalized);
  if (_matches(normalized, tokens, _fireWords)) return IncidentType.fire;
  if (_matches(normalized, tokens, _accidentWords)) {
    return IncidentType.accident;
  }
  if (_matches(normalized, tokens, _securityWords)) {
    return IncidentType.security;
  }
  if (_matches(normalized, tokens, _dangerWords)) return IncidentType.danger;
  if (_matches(normalized, tokens, _medicalWords)) return IncidentType.medical;
  return null;
}

/// True when the text mentions a life-threatening sign (unconscious, not
/// breathing, heavy bleeding, ...) - always raises urgency to High.
bool mentionsCriticalSigns(String text) {
  final normalized = normalizeText(text);
  return _matches(normalized, _tokens(normalized), _criticalWords);
}

const _yesWords = {
  'yes',
  'y',
  'yeah',
  'yep',
  'yup',
  'sure',
  'ok',
  'okay',
  'نعم',
  'ايوه',
  'ايوا',
  'اي',
  'ايه',
  'اكيد',
  'صح',
  'طيب',
  'موافق',
  'اجل',
  'بلي',
  'تمام',
};
const _noWords = {
  'no',
  'n',
  'nope',
  'nah',
  'لا',
  'لاء',
  'لأ',
  'كلا',
  'مش',
  'ابدا',
  'لااا',
};

/// Parses a yes/no answer; null when the text is neither.
bool? parseYesNo(String text) {
  final normalized = normalizeText(text);
  if (normalized.isEmpty) return null;
  final first = _tokens(normalized).firstOrNull ?? normalized;
  if (_yesWords.contains(normalized) || _yesWords.contains(first)) return true;
  if (_noWords.contains(normalizeText(first)) ||
      _noWords.contains(normalized)) {
    return false;
  }
  return null;
}

/// Number of injured people (3 means "3 or more"); null when unclear.
int? parseInjuredCount(String text) {
  final normalized = normalizeText(text);
  if (normalized.isEmpty) return null;
  final digits = RegExp(r'\d+').firstMatch(normalized);
  if (digits != null) return int.parse(digits.group(0)!).clamp(0, 3);

  final tokens = _tokens(normalized).toSet();
  // Multi-word phrases match as substrings; single words only as whole
  // words, so "one" doesn't match "someone".
  bool any(List<String> words) => words.any(
    (w) => w.contains(' ') ? normalized.contains(w) : tokens.contains(w),
  );
  if (any([
    'none',
    'nobody',
    'no one',
    'zero',
    'لا احد',
    'ولا احد',
    'لا يوجد',
    'ما فيه',
    'صفر',
    'محد',
    'ماحد',
  ])) {
    return 0;
  }
  if (any([
    'many',
    'several',
    'multiple',
    'lots',
    'كثير',
    'كثيرين',
    'عده',
    'عديد',
    'مجموعه',
    'ثلاثه',
    'ثلاث',
    'three',
  ])) {
    return 3;
  }
  if (any(['two', 'both', 'اثنين', 'اثنان', 'شخصين', 'اثنتين'])) return 2;
  if (any([
    'one',
    'me',
    'myself',
    'single',
    'واحد',
    'واحده',
    'شخص',
    'انا',
    'نفسي',
  ])) {
    return 1;
  }
  if (parseYesNo(normalized) == false) return 0;
  return null;
}

/// Display form of an injured count: 0, 1, 2 or 3+.
String injuredLabel(int count) => count >= 3 ? '3+' : '$count';

/// Urgency translation key for the assistant summary.
/// High: medical, fire, traffic accident or personal danger; anyone not
/// conscious; any injured person; or a life-threatening sign in the text.
/// Medium otherwise (security incident / other with the user conscious).
String urgencyKeyFor({
  required IncidentType? type,
  required bool? conscious,
  required int injured,
  required bool criticalSigns,
}) {
  if (criticalSigns || conscious == false || injured > 0) {
    return 'assistant_urgency_high';
  }
  if (type == IncidentType.medical ||
      type == IncidentType.fire ||
      type == IncidentType.accident ||
      type == IncidentType.danger) {
    return 'assistant_urgency_high';
  }
  return 'assistant_urgency_medium';
}
