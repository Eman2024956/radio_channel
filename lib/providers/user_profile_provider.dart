import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider extends ChangeNotifier {
  static const String _keyUserName = 'user_profile_name';
  static const String _keyIsLoggedIn = 'user_profile_is_logged_in';
  static const String _keySignInDate = 'user_profile_signin_date';

  String _userName = '';
  bool _isLoggedIn = false;
  String _signInDate = '';
  bool _isInitialized = false;

  UserProfileProvider() {
    _loadFromCache();
  }

  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  String get signInDate => _signInDate;
  bool get isInitialized => _isInitialized;

  String get displayName => _isLoggedIn && _userName.trim().isNotEmpty
      ? _userName.trim()
      : 'Guest User';

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString(_keyUserName) ?? '';
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _signInDate = prefs.getString(_keySignInDate) ?? '';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile from cache: $e');
      _isInitialized = true;
    }
  }

  Future<bool> signIn(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final nowStr = DateTime.now().toIso8601String().split('T').first;
      await prefs.setString(_keyUserName, cleanName);
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keySignInDate, nowStr);

      _userName = cleanName;
      _isLoggedIn = true;
      _signInDate = nowStr;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserName);
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keySignInDate);

      _userName = '';
      _isLoggedIn = false;
      _signInDate = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
