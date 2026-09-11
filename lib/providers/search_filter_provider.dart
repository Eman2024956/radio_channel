import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/radio_station.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/genre_tag.dart';
import '../services/radio_api_service.dart';

class SearchFilterProvider extends ChangeNotifier {
  final RadioApiService _apiService = RadioApiService();

  // Search parameters
  String _query = '';
  String? _selectedCountry;
  String? _selectedCountryCode;
  String? _selectedLanguage;
  String? _selectedGenre;
  String _selectedCodec = 'ALL';
  int _minBitrate = 0;
  String _orderBy = 'clickcount';
  bool _reverse = true;

  // Search state
  bool _isLoading = false;
  String? _errorMessage;
  List<RadioStation> _results = [];
  Timer? _debounceTimer;

  // Cached filter options
  List<CountryItem> _countries = [];
  List<LanguageItem> _languages = [];
  List<GenreTag> _tags = [];
  bool _filtersLoaded = false;

  SearchFilterProvider() {
    _loadFilterOptions();
    executeSearch();
  }

  String get query => _query;
  String? get selectedCountry => _selectedCountry;
  String? get selectedCountryCode => _selectedCountryCode;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedGenre => _selectedGenre;
  String get selectedCodec => _selectedCodec;
  int get minBitrate => _minBitrate;
  String get orderBy => _orderBy;
  bool get reverse => _reverse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RadioStation> get results => _results;
  List<CountryItem> get countries => _countries;
  List<LanguageItem> get languages => _languages;
  List<GenreTag> get tags => _tags;
  bool get filtersLoaded => _filtersLoaded;

  int get activeFilterCount {
    int count = 0;
    if (_selectedCountryCode != null && _selectedCountryCode!.isNotEmpty) count++;
    if (_selectedLanguage != null && _selectedLanguage!.isNotEmpty) count++;
    if (_selectedGenre != null && _selectedGenre!.isNotEmpty) count++;
    if (_selectedCodec != 'ALL') count++;
    if (_minBitrate > 0) count++;
    if (_orderBy != 'clickcount') count++;
    return count;
  }

  Future<void> _loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _apiService.getCountries(limit: 120),
        _apiService.getLanguages(limit: 80),
        _apiService.getPopularTags(limit: 80),
      ]);
      _countries = results[0] as List<CountryItem>;
      _languages = results[1] as List<LanguageItem>;
      _tags = results[2] as List<GenreTag>;
      _filtersLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  void onQueryChanged(String val) {
    _query = val;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      executeSearch();
    });
  }

  void setCountry(String? name, String? code) {
    _selectedCountry = (name != null && name.isNotEmpty) ? name : null;
    _selectedCountryCode = (code != null && code.isNotEmpty) ? code : null;
    executeSearch();
  }

  void setLanguage(String? lang) {
    _selectedLanguage = (lang != null && lang.isNotEmpty) ? lang : null;
    executeSearch();
  }

  void setGenre(String? genre) {
    _selectedGenre = (genre != null && genre.isNotEmpty) ? genre : null;
    executeSearch();
  }

  void setCodec(String codec) {
    _selectedCodec = codec;
    executeSearch();
  }

  void setMinBitrate(int bitrate) {
    _minBitrate = bitrate;
    executeSearch();
  }

  void setOrderBy(String order, [bool? rev]) {
    _orderBy = order;
    if (rev != null) _reverse = rev;
    executeSearch();
  }

  void resetFilters() {
    _selectedCountry = null;
    _selectedCountryCode = null;
    _selectedLanguage = null;
    _selectedGenre = null;
    _selectedCodec = 'ALL';
    _minBitrate = 0;
    _orderBy = 'clickcount';
    _reverse = true;
    executeSearch();
  }

  Future<void> executeSearch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stations = await _apiService.searchStations(
        name: _query,
        country: _selectedCountry,
        countryCode: _selectedCountryCode,
        language: _selectedLanguage,
        tag: _selectedGenre,
        codec: _selectedCodec == 'ALL' ? null : _selectedCodec,
        bitrateMin: _minBitrate > 0 ? _minBitrate : null,
        order: _orderBy,
        reverse: _reverse,
        limit: 60,
      );
      _results = stations;
    } catch (e) {
      debugPrint('Search error: $e');
      _errorMessage = 'Failed to fetch stations. Please try again.';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
