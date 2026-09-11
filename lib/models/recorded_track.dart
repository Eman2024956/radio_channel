import 'dart:convert';

class RecordedTrack {
  final String id;
  final String stationName;
  final String stationUuid;
  final String filePath;
  final int durationSeconds;
  final int fileSizeBytes;
  final DateTime recordedAt;

  RecordedTrack({
    required this.id,
    required this.stationName,
    required this.stationUuid,
    required this.filePath,
    required this.durationSeconds,
    required this.fileSizeBytes,
    required this.recordedAt,
  });

  String get formattedDuration {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (fileSizeBytes <= 0) return '0 KB';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stationName': stationName,
        'stationUuid': stationUuid,
        'filePath': filePath,
        'durationSeconds': durationSeconds,
        'fileSizeBytes': fileSizeBytes,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory RecordedTrack.fromJson(Map<String, dynamic> json) => RecordedTrack(
        id: json['id']?.toString() ?? '',
        stationName: json['stationName']?.toString() ?? 'Recorded Channel',
        stationUuid: json['stationUuid']?.toString() ?? '',
        filePath: json['filePath']?.toString() ?? '',
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
        fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
        recordedAt: DateTime.tryParse(json['recordedAt']?.toString() ?? '') ?? DateTime.now(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory RecordedTrack.fromJsonString(String str) =>
      RecordedTrack.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
