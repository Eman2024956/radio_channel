import 'dart:convert';

class RadioStation {
  final String stationUuid;
  final String name;
  final String url;
  final String urlResolved;
  final String homepage;
  final String favicon;
  final String tags;
  final String country;
  final String countryCode;
  final String state;
  final String language;
  final int votes;
  final String codec;
  final int bitrate;
  final bool isHls;
  final int clickCount;

  RadioStation({
    required this.stationUuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    this.homepage = '',
    this.favicon = '',
    this.tags = '',
    this.country = '',
    this.countryCode = '',
    this.state = '',
    this.language = '',
    this.votes = 0,
    this.codec = '',
    this.bitrate = 0,
    this.isHls = false,
    this.clickCount = 0,
  });

  /// Returns clean streamable URL (fallback to url if urlResolved is empty)
  String get streamUrl {
    if (urlResolved.trim().isNotEmpty) {
      return urlResolved.trim();
    }
    return url.trim();
  }

  /// Clean display name
  String get displayName {
    final clean = name.trim();
    return clean.isEmpty ? 'Unnamed Station' : clean;
  }

  /// Tag list parsed from comma-separated string
  List<String> get tagList {
    if (tags.trim().isEmpty) return [];
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(6)
        .toList();
  }

  /// Formatted bitrate display (e.g. "128 kbps")
  String get bitrateDisplay {
    if (bitrate <= 0) return 'Variable';
    return '$bitrate kbps';
  }

  /// Formatted audio format badge (e.g. "MP3 • 128 kbps")
  String get formatBadge {
    final c = codec.trim().toUpperCase();
    if (c.isEmpty && bitrate <= 0) return 'LIVE';
    if (c.isEmpty) return bitrateDisplay;
    if (bitrate <= 0) return c;
    return '$c • $bitrateDisplay';
  }

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      stationUuid: json['stationuuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      urlResolved: json['url_resolved']?.toString() ?? json['url']?.toString() ?? '',
      homepage: json['homepage']?.toString() ?? '',
      favicon: json['favicon']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryCode: json['countrycode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      votes: (json['votes'] is num) ? (json['votes'] as num).toInt() : int.tryParse('${json['votes']}') ?? 0,
      codec: json['codec']?.toString() ?? '',
      bitrate: (json['bitrate'] is num) ? (json['bitrate'] as num).toInt() : int.tryParse('${json['bitrate']}') ?? 0,
      isHls: json['hls'] == 1 || json['hls'] == true || '${json['hls']}' == '1',
      clickCount: (json['clickcount'] is num) ? (json['clickcount'] as num).toInt() : int.tryParse('${json['clickcount']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationuuid': stationUuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'homepage': homepage,
      'favicon': favicon,
      'tags': tags,
      'country': country,
      'countrycode': countryCode,
      'state': state,
      'language': language,
      'votes': votes,
      'codec': codec,
      'bitrate': bitrate,
      'hls': isHls ? 1 : 0,
      'clickcount': clickCount,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory RadioStation.fromJsonString(String source) =>
      RadioStation.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioStation &&
          runtimeType == other.runtimeType &&
          stationUuid == other.stationUuid;

  @override
  int get hashCode => stationUuid.hashCode;
}
