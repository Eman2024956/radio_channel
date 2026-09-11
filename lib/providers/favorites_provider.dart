import 'package:flutter/foundation.dart';
import '../models/radio_station.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<RadioStation> _favorites = [];
  List<RadioStation> _recents = [];
  bool _isLoaded = false;

  FavoritesProvider() {
    _loadInitialData();
  }

  List<RadioStation> get favorites => List.unmodifiable(_favorites);
  List<RadioStation> get recents => List.unmodifiable(_recents);
  bool get isLoaded => _isLoaded;

  Future<void> _loadInitialData() async {
    _favorites = await _storageService.loadFavorites();
    _recents = await _storageService.loadRecents();
    _isLoaded = true;
    notifyListeners();
  }

  bool isFavorite(String stationUuid) {
    return _favorites.any((s) => s.stationUuid == stationUuid);
  }

  Future<void> toggleFavorite(RadioStation station) async {
    final index = _favorites.indexWhere((s) => s.stationUuid == station.stationUuid);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.insert(0, station);
    }
    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }

  Future<void> addToRecents(RadioStation station) async {
    // Remove if already present so it floats to top
    _recents.removeWhere((s) => s.stationUuid == station.stationUuid);
    _recents.insert(0, station);
    if (_recents.length > 40) {
      _recents = _recents.sublist(0, 40);
    }
    notifyListeners();
    await _storageService.saveRecents(_recents);
  }

  Future<void> clearRecents() async {
    _recents.clear();
    notifyListeners();
    await _storageService.saveRecents(_recents);
  }
}
