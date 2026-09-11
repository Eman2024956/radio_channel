import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localePrefKey = 'app_user_locale_v1';
  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_localePrefKey);
    if (langCode == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, _locale.languageCode);
  }

  Future<void> toggleLanguage() => toggleLocale();

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, _locale.languageCode);
  }
}
