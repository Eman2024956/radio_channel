import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/radio_station.dart';
import '../models/recorded_track.dart';

typedef RecordingProgressCallback = void Function(int elapsedSeconds, int bytesDownloaded);

class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  factory RecordingService() => _instance;
  RecordingService._internal();

  http.Client? _activeClient;
  IOSink? _activeSink;
  Timer? _recordingTimer;
  bool _isCancelled = false;

  /// Check and request storage & audio permissions on real device
  Future<bool> checkAndRequestPermissions() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        // Android 13+ (API 33+) requires READ_MEDIA_AUDIO for audio access
        final audioStatus = await Permission.audio.status;
        if (!audioStatus.isGranted) {
          final reqAudio = await Permission.audio.request();
          if (reqAudio.isGranted) return true;
        } else {
          return true;
        }

        // For Android 12 and below, check storage permission
        final storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          final reqStorage = await Permission.storage.request();
          return reqStorage.isGranted;
        }
        return true;
      } else if (Platform.isIOS) {
        return true;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
    return true;
  }

  /// Get or create downloads destination directory
  Future<Directory> getRecordingsDirectory() async {
    if (!kIsWeb && Platform.isAndroid) {
      // Try public Download folder on Android device
      final publicDownload = Directory('/storage/emulated/0/Download/RadioRecordings');
      try {
        if (!await publicDownload.exists()) {
          await publicDownload.create(recursive: true);
        }
        return publicDownload;
      } catch (_) {
        // Fallback to external/app directory if restricted
      }

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final dir = Directory('${extDir.path}/RadioRecordings');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      }
    }

    // Default to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/RadioRecordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Record stream for target duration seconds
  Future<RecordedTrack?> recordStream({
    required RadioStation station,
    required int durationSeconds,
    required RecordingProgressCallback onProgress,
  }) async {
    _isCancelled = false;
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission was not granted. Please allow storage access in App Settings.');
    }

    final targetDir = await getRecordingsDirectory();
    final sanitizedName = station.name
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final filenameSafe = sanitizedName.isEmpty ? 'RadioStation' : sanitizedName;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${targetDir.path}/${filenameSafe}_$timestamp.mp3');

    _activeSink = file.openWrite();
    _activeClient = http.Client();

    int elapsedSeconds = 0;
    int bytesDownloaded = 0;

    final completer = Completer<RecordedTrack?>();

    // Start timer for progress and auto-stop
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isCancelled) {
        timer.cancel();
        return;
      }

      elapsedSeconds++;
      onProgress(elapsedSeconds, bytesDownloaded);

      if (elapsedSeconds >= durationSeconds) {
        timer.cancel();
        await _finishRecording(file, station, elapsedSeconds, bytesDownloaded, completer);
      }
    });

    try {
      final request = http.Request('GET', Uri.parse(station.streamUrl));
      request.headers['User-Agent'] = 'RadioChannelApp/1.0';
      final response = await _activeClient!.send(request);

      response.stream.listen(
        (chunk) {
          if (_isCancelled) return;
          bytesDownloaded += chunk.length;
          _activeSink?.add(chunk);
        },
        onError: (err) async {
          debugPrint('Stream download error: $err');
          _recordingTimer?.cancel();
          if (!completer.isCompleted) {
            await _finishRecording(file, station, elapsedSeconds, bytesDownloaded, completer);
          }
        },
        onDone: () async {
          _recordingTimer?.cancel();
          if (!completer.isCompleted) {
            await _finishRecording(file, station, elapsedSeconds, bytesDownloaded, completer);
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      _recordingTimer?.cancel();
      await _activeSink?.close();
      _activeClient?.close();
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  Future<void> _finishRecording(
    File file,
    RadioStation station,
    int durationSeconds,
    int bytesDownloaded,
    Completer<RecordedTrack?> completer,
  ) async {
    try {
      await _activeSink?.flush();
      await _activeSink?.close();
      _activeSink = null;
    } catch (_) {}

    _activeClient?.close();
    _activeClient = null;

    if (bytesDownloaded > 5000 && await file.exists()) {
      final track = RecordedTrack(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stationName: station.displayName,
        stationUuid: station.stationUuid,
        filePath: file.path,
        durationSeconds: durationSeconds,
        fileSizeBytes: bytesDownloaded,
        recordedAt: DateTime.now(),
      );
      if (!completer.isCompleted) {
        completer.complete(track);
      }
    } else {
      if (await file.exists()) {
        await file.delete();
      }
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  }

  /// Cancel current recording
  Future<void> stopRecording() async {
    _isCancelled = true;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    try {
      await _activeSink?.flush();
      await _activeSink?.close();
    } catch (_) {}
    _activeSink = null;
    _activeClient?.close();
    _activeClient = null;
  }
}
