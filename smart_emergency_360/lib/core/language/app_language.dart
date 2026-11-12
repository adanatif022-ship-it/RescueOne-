import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

enum AppLocale { en, ar }

/// App-wide bilingual (English/Arabic) language controller.
///
/// Screens read strings through `context.tr('key')` (see the BuildContext
/// extension below) instead of hard-coding text, so switching languages
/// updates every screen and flips text direction (LTR/RTL) automatically.
class AppLanguage extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  AppLocale _locale = AppLocale.en;
  AppLocale get locale => _locale;

  bool get isArabic => _locale == AppLocale.ar;

  TextDirection get textDirection =>
      _locale == AppLocale.ar ? TextDirection.rtl : TextDirection.ltr;

  Locale get materialLocale =>
      _locale == AppLocale.ar ? const Locale('ar') : const Locale('en');

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _locale = saved == 'ar' ? AppLocale.ar : AppLocale.en;
    } else {
      // First launch: follow the phone's language.
      final device = WidgetsBinding.instance.platformDispatcher.locale;
      _locale = device.languageCode == 'ar' ? AppLocale.ar : AppLocale.en;
    }
    notifyListeners();
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await persist();
  }

  /// Saves the current language (also used after "Delete all data").
  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _locale == AppLocale.ar ? 'ar' : 'en');
  }

  Future<void> toggle() =>
      setLocale(_locale == AppLocale.en ? AppLocale.ar : AppLocale.en);

  String tr(String key) {
    final map = translations[key];
    if (map == null) return key;
    return map[_locale] ?? map[AppLocale.en] ?? key;
  }

  /// [tr] with `{name}` placeholders filled from [args].
  String trArgs(String key, Map<String, String> args) {
    var text = tr(key);
    args.forEach((name, value) => text = text.replaceAll('{$name}', value));
    return text;
  }

  /// Joins items with the language's comma ("، " in Arabic).
  String joinList(Iterable<String> items) => items.join(tr('comma'));
}

extension AppLanguageContext on BuildContext {
  /// Rebuilds the caller whenever the language changes.
  AppLanguage get lang => Provider.of<AppLanguage>(this);

  /// Shorthand for `context.lang.tr('key')`.
  ///
  /// Only safe to call during `build()` (directly, or from a builder
  /// callback such as `ListView.builder`'s `itemBuilder`, which Flutter
  /// runs inside a build scope). Calling this with listen:true from
  /// initState(), an event handler (onPressed/onTap), or after an
  /// `await` throws a Provider assertion because nothing is building
  /// at that point - use [trRead] there instead.
  String tr(String key) => Provider.of<AppLanguage>(this).tr(key);

  /// Non-listening translation lookup, safe to call from initState(),
  /// event handlers, async callbacks, or anywhere outside build().
  String trRead(String key) =>
      Provider.of<AppLanguage>(this, listen: false).tr(key);

  /// Listening `{placeholder}` translation (build only).
  String trArgs(String key, Map<String, String> args) =>
      Provider.of<AppLanguage>(this).trArgs(key, args);

  /// Non-listening `{placeholder}` translation (event handlers).
  String trArgsRead(String key, Map<String, String> args) =>
      Provider.of<AppLanguage>(this, listen: false).trArgs(key, args);
}
