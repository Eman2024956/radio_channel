import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_station.dart';
import '../models/recorded_track.dart';
import '../services/recording_service.dart';

class DownloadProvider extends ChangeNotifier {
  static const String _savedTracksKey = 'saved_recordings_tracks_v1';
  final RecordingService _recordingService = RecordingService();
  final AudioPlayer _localPlayer = AudioPlayer();

  bool _isRecording = false;
  RadioStation? _recordingStation;
  int _targetDurationSeconds = 60;
  int _elapsedSeconds = 0;
  int _bytesRecorded = 0;
  String? _recordingError;

  List<RecordedTrack> _savedTracks = [];
  RecordedTrack? _currentPlayingTrack;
  bool _isPlayingTrack = false;

  DownloadProvider() {
    _loadSavedTracks();
    _initLocalPlayer();
  }

  bool get isRecording => _isRecording;
  RadioStation? get recordingStation => _recordingStation;
  int get targetDurationSeconds => _targetDurationSeconds;
  int get elapsedSeconds => _elapsedSeconds;
  int get bytesRecorded => _bytesRecorded;
  String? get recordingError => _recordingError;
  List<RecordedTrack> get savedTracks => List.unmodifiable(_savedTracks);
  RecordedTrack? get currentPlayingTrack => _currentPlayingTrack;
  bool get isPlayingTrack => _isPlayingTrack;

  double get progressPercentage {
    if (_targetDurationSeconds <= 0) return 0.0;
    return (_elapsedSeconds / _targetDurationSeconds).clamp(0.0, 1.0);
  }

  String get formattedBytes {
    if (_bytesRecorded < 1024 * 1024) {
      return '${(_bytesRecorded / 1024).toStringAsFixed(1)} KB';
    }
    return '${(_bytesRecorded / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _initLocalPlayer() {
    _localPlayer.onPlayerStateChanged.listen((state) {
      _isPlayingTrack = (state == PlayerState.playing);
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _isPlayingTrack = false;
        _currentPlayingTrack = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadSavedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedTracksKey);
    if (list != null) {
      _savedTracks = list.map((s) {
        try {
          return RecordedTrack.fromJsonString(s);
        } catch (_) {
          return null;
        }
      }).whereType<RecordedTrack>().toList();
      notifyListeners();
    }
  }

  Future<void> _persistTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _savedTracks.map((t) => t.toJsonString()).toList();
    await prefs.setStringList(_savedTracksKey, list);
  }

  /// Start recording stream for specified seconds
  Future<void> startRecording(RadioStation station, int durationSeconds) async {
    if (_isRecording) return;

    _isRecording = true;
    _recordingStation = station;
    _targetDurationSeconds = durationSeconds;
    _elapsedSeconds = 0;
    _bytesRecorded = 0;
    _recordingError = null;
    notifyListeners();

    try {
      final track = await _recordingService.recordStream(
        station: station,
        durationSeconds: durationSeconds,
        onProgress: (elapsed, bytes) {
          _elapsedSeconds = elapsed;
          _bytesRecorded = bytes;
          notifyListeners();
        },
      );

      if (track != null) {
        _savedTracks.insert(0, track);
        await _persistTracks();
      }
    } catch (e) {
      debugPrint('Recording error: $e');
      _recordingError = e.toString();
    } finally {
      _isRecording = false;
      _recordingStation = null;
      notifyListeners();
    }
  }

  /// Cancel or stop ongoing recording
  Future<void> stopRecording() async {
    await _recordingService.stopRecording();
    _isRecording = false;
    _recordingStation = null;
    notifyListeners();
  }

  /// Play a recorded local MP3 track
  Future<void> playTrack(RecordedTrack track) async {
    if (_currentPlayingTrack?.id == track.id && _isPlayingTrack) {
      await _localPlayer.pause();
      _isPlayingTrack = false;
      notifyListeners();
      return;
    }

    final file = File(track.filePath);
    if (!await file.exists()) {
      _savedTracks.removeWhere((t) => t.id == track.id);
      await _persistTracks();
      notifyListeners();
      return;
    }

    _currentPlayingTrack = track;
    await _localPlayer.stop();
    await _localPlayer.play(DeviceFileSource(track.filePath));
    _isPlayingTrack = true;
    notifyListeners();
  }

  Future<void> stopTrack() async {
    await _localPlayer.stop();
    _currentPlayingTrack = null;
    _isPlayingTrack = false;
    notifyListeners();
  }

  /// Delete a recorded file
  Future<void> deleteTrack(RecordedTrack track) async {
    if (_currentPlayingTrack?.id == track.id) {
      await stopTrack();
    }

    try {
      final file = File(track.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }

    _savedTracks.removeWhere((t) => t.id == track.id);
    await _persistTracks();
    notifyListeners();
  }

  @override
  void dispose() {
    _localPlayer.dispose();
    super.dispose();
  }
}
