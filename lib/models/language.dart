class LanguageItem {
  final String name;
  final String isoCode;
  final int stationCount;

  const LanguageItem({
    required this.name,
    required this.isoCode,
    required this.stationCount,
  });

  factory LanguageItem.fromJson(Map<String, dynamic> json) {
    return LanguageItem(
      name: json['name']?.toString() ?? '',
      isoCode: json['iso_639']?.toString() ?? '',
      stationCount: (json['stationcount'] is num)
          ? (json['stationcount'] as num).toInt()
          : int.tryParse('${json['stationcount']}') ?? 0,
    );
  }
}
