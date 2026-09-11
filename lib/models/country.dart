class CountryItem {
  final String name;
  final String isoCode;
  final int stationCount;

  const CountryItem({
    required this.name,
    required this.isoCode,
    required this.stationCount,
  });

  factory CountryItem.fromJson(Map<String, dynamic> json) {
    return CountryItem(
      name: json['name']?.toString() ?? '',
      isoCode: json['iso_3166_1']?.toString() ?? '',
      stationCount: (json['stationcount'] is num)
          ? (json['stationcount'] as num).toInt()
          : int.tryParse('${json['stationcount']}') ?? 0,
    );
  }
}
