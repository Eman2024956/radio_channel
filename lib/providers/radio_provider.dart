import 'package:flutter/foundation.dart';
import '../models/radio_station.dart';
import '../models/genre_tag.dart';
import '../services/radio_api_service.dart';

class RadioProvider extends ChangeNotifier {
  final RadioApiService _apiService = RadioApiService();

  bool _isLoading = false;
  String? _errorMessage;

  List<RadioStation> _topClickedStations = [];
  List<RadioStation> _topVotedStations = [];
  List<GenreTag> _popularTags = [];
  final Map<String, List<RadioStation>> _countryStations = {};
  String _selectedCountryCode = 'IQ'; // Default quick highlight: Iraq / Middle East

  RadioProvider() {
    loadHomeData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RadioStation> get topClickedStations => _topClickedStations;
  List<RadioStation> get topVotedStations => _topVotedStations;
  List<GenreTag> get popularTags => _popularTags;
  String get selectedCountryCode => _selectedCountryCode;
  List<RadioStation> get currentCountryStations => _countryStations[_selectedCountryCode] ?? [];

  RadioStation? get featuredStation {
    if (_topClickedStations.isNotEmpty) {
      return _topClickedStations.first;
    }
    if (_topVotedStations.isNotEmpty) {
      return _topVotedStations.first;
    }
    return null;
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getTopClickStations(limit: 25),
        _apiService.getTopVoteStations(limit: 25),
        _apiService.getPopularTags(limit: 30),
        _apiService.searchStations(countryCode: _selectedCountryCode, limit: 15, order: 'clickcount'),
      ]);

      _topClickedStations = results[0] as List<RadioStation>;
      _topVotedStations = results[1] as List<RadioStation>;
      _popularTags = results[2] as List<GenreTag>;
      _countryStations[_selectedCountryCode] = results[3] as List<RadioStation>;
    } catch (e) {
      debugPrint('Error loading home radio data: $e');
      _errorMessage = 'Failed to load live radio channels. Check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setQuickCountry(String countryCode) async {
    if (_selectedCountryCode == countryCode && (_countryStations[countryCode]?.isNotEmpty ?? false)) {
      return;
    }
    _selectedCountryCode = countryCode;
    notifyListeners();

    if (!_countryStations.containsKey(countryCode) || _countryStations[countryCode]!.isEmpty) {
      try {
        final stations = await _apiService.searchStations(
          countryCode: countryCode,
          limit: 15,
          order: 'clickcount',
        );
        _countryStations[countryCode] = stations;
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading country stations: $e');
      }
    }
  }
}
