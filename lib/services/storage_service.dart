import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_station.dart';

class StorageService {
  static const String _favoritesKey = 'user_favorite_stations_v1';
  static const String _recentsKey = 'user_recent_stations_v1';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Load favorite stations
  Future<List<RadioStation>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList(_favoritesKey);
    if (encodedList == null || encodedList.isEmpty) return [];

    final List<RadioStation> stations = [];
    for (final item in encodedList) {
      try {
        stations.add(RadioStation.fromJsonString(item));
      } catch (_) {}
    }
    return stations;
  }

  /// Save favorites list
  Future<void> saveFavorites(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = stations.map((s) => s.toJsonString()).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  /// Load recently played stations
  Future<List<RadioStation>> loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList(_recentsKey);
    if (encodedList == null || encodedList.isEmpty) return [];

    final List<RadioStation> stations = [];
    for (final item in encodedList) {
      try {
        stations.add(RadioStation.fromJsonString(item));
      } catch (_) {}
    }
    return stations;
  }

  /// Save recent stations (cap at 40)
  Future<void> saveRecents(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = stations.take(40).toList();
    final encoded = capped.map((s) => s.toJsonString()).toList();
    await prefs.setStringList(_recentsKey, encoded);
  }
}
