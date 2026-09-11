class GenreTag {
  final String name;
  final int stationCount;

  const GenreTag({
    required this.name,
    required this.stationCount,
  });

  factory GenreTag.fromJson(Map<String, dynamic> json) {
    return GenreTag(
      name: json['name']?.toString() ?? '',
      stationCount: (json['stationcount'] is num)
          ? (json['stationcount'] as num).toInt()
          : int.tryParse('${json['stationcount']}') ?? 0,
    );
  }
}
