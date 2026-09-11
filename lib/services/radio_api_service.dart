import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/genre_tag.dart';

class RadioApiService {
  static final RadioApiService _instance = RadioApiService._internal();
  factory RadioApiService() => _instance;
  RadioApiService._internal();

  static const List<String> fallbackServers = [
    'de1.api.radio-browser.info',
    'nl1.api.radio-browser.info',
    'at1.api.radio-browser.info',
  ];

  String _currentServer = fallbackServers.first;
  bool _serverResolved = false;

  static const Map<String, String> _headers = {
    'User-Agent': 'RadioChannelApp/1.0 (Flutter; Mobile/Desktop/Web)',
    'Accept': 'application/json',
  };

  /// Dynamically discover and set the best available mirror server
  Future<void> initServer() async {
    if (_serverResolved) return;
    try {
      final uri = Uri.parse('https://all.api.radio-browser.info/json/servers');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        if (list.isNotEmpty && list[0]['name'] != null) {
          _currentServer = list[0]['name'].toString();
          _serverResolved = true;
          return;
        }
      }
    } catch (e) {
      debugPrint('Error discovering server, using default: $e');
    }
    _currentServer = fallbackServers.first;
    _serverResolved = true;
  }

  /// Internal request runner with mirror failover
  Future<http.Response> _getWithFallback(String path, [Map<String, String>? queryParams]) async {
    await initServer();

    final serversToTry = [_currentServer, ...fallbackServers.where((s) => s != _currentServer)];
    dynamic lastError;

    for (final server in serversToTry) {
      try {
        final uri = Uri.https(server, path, queryParams);
        final response = await http.get(uri, headers: _headers).timeout(
          const Duration(seconds: 9),
        );
        if (response.statusCode == 200) {
          _currentServer = server;
          return response;
        }
      } catch (e) {
        lastError = e;
        debugPrint('Mirror $server failed: $e, trying next mirror...');
      }
    }

    throw Exception('Failed to connect to Radio Browser API: $lastError');
  }

  /// Search radio stations with comprehensive filters
  Future<List<RadioStation>> searchStations({
    String? name,
    String? country,
    String? countryCode,
    String? language,
    String? tag,
    String? codec,
    int? bitrateMin,
    String order = 'clickcount', // 'clickcount', 'votes', 'name', 'bitrate', 'random'
    bool reverse = true,
    int limit = 50,
    int offset = 0,
    bool hideBroken = true,
  }) async {
    final Map<String, String> query = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'order': order,
      'reverse': reverse ? 'true' : 'false',
      'hidebroken': hideBroken ? 'true' : 'false',
    };

    if (name != null && name.trim().isNotEmpty) {
      query['name'] = name.trim();
    }
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      query['countrycode'] = countryCode.trim();
    } else if (country != null && country.trim().isNotEmpty) {
      query['country'] = country.trim();
    }
    if (language != null && language.trim().isNotEmpty) {
      query['language'] = language.trim();
    }
    if (tag != null && tag.trim().isNotEmpty) {
      query['tag'] = tag.trim();
    }
    if (codec != null && codec.trim().isNotEmpty && codec.toLowerCase() != 'all') {
      query['codec'] = codec.trim();
    }
    if (bitrateMin != null && bitrateMin > 0) {
      query['bitrateMin'] = bitrateMin.toString();
    }

    final response = await _getWithFallback('/json/stations/search', query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch top clicked stations worldwide
  Future<List<RadioStation>> getTopClickStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/topclick/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch top voted stations worldwide
  Future<List<RadioStation>> getTopVoteStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/topvote/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch recently modified stations
  Future<List<RadioStation>> getLastChangedStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/lastchange/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch list of countries with station counts
  Future<List<CountryItem>> getCountries({String? search, int limit = 150}) async {
    final Map<String, String> query = {
      'order': 'stationcount',
      'reverse': 'true',
      'limit': limit.toString(),
    };
    final path = (search != null && search.trim().isNotEmpty)
        ? '/json/countries/${Uri.encodeComponent(search.trim())}'
        : '/json/countries';

    final response = await _getWithFallback(path, query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((j) => CountryItem.fromJson(j as Map<String, dynamic>))
        .where((c) => c.name.trim().isNotEmpty && c.stationCount > 0)
        .toList();
  }

  /// Fetch list of languages with station counts
  Future<List<LanguageItem>> getLanguages({String? search, int limit = 100}) async {
    final Map<String, String> query = {
      'order': 'stationcount',
      'reverse': 'true',
      'limit': limit.toString(),
    };
    final path = (search != null && search.trim().isNotEmpty)
        ? '/json/languages/${Uri.encodeComponent(search.trim())}'
        : '/json/languages';

    final response = await _getWithFallback(path, query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((j) => LanguageItem.fromJson(j as Map<String, dynamic>))
        .where((l) => l.name.trim().isNotEmpty && l.stationCount > 0)
        .toList();
  }

  /// Fetch list of popular tags/genres
  Future<List<GenreTag>> getPopularTags({String? search, int limit = 80}) async {
    final Map<String, String> query = {
      'order': 'stationcount',
      'reverse': 'true',
      'limit': limit.toString(),
    };
    final path = (search != null && search.trim().isNotEmpty)
        ? '/json/tags/${Uri.encodeComponent(search.trim())}'
        : '/json/tags';

    final response = await _getWithFallback(path, query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((j) => GenreTag.fromJson(j as Map<String, dynamic>))
        .where((t) => t.name.trim().isNotEmpty && t.stationCount > 10)
        .toList();
  }

  /// Register station play/click in Radio Browser community stats
  Future<String?> registerStationClick(String stationUuid) async {
    try {
      final response = await _getWithFallback('/json/url/$stationUuid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url']?.toString();
      }
    } catch (e) {
      debugPrint('Failed to register station click: $e');
    }
    return null;
  }
}
