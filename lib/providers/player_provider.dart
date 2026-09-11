import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/radio_station.dart';
import '../services/audio_player_service.dart';
import '../services/radio_api_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final RadioApiService _apiService = RadioApiService();

  RadioStation? _currentStation;
  AudioPlaybackStatus _status = AudioPlaybackStatus.idle;
  String? _errorMessage;
  double _volume = 1.0;
  StreamSubscription? _statusSubscription;

  // Callback to inform favorites provider to add to recents
  Function(RadioStation station)? onStationPlayed;

  PlayerProvider() {
    _status = _audioService.currentStatus;
    _volume = _audioService.volume;
    _statusSubscription = _audioService.statusStream.listen((newStatus) {
      _status = newStatus;
      _errorMessage = _audioService.errorMessage;
      notifyListeners();
    });
  }

  RadioStation? get currentStation => _currentStation;
  AudioPlaybackStatus get status => _status;
  String? get errorMessage => _errorMessage;
  double get volume => _volume;

  bool get isPlaying => _status == AudioPlaybackStatus.playing;
  bool get isBuffering => _status == AudioPlaybackStatus.buffering;
  bool get isPaused => _status == AudioPlaybackStatus.paused;
  bool get hasActiveStation => _currentStation != null;

  /// Play a radio station
  Future<void> playStation(RadioStation station) async {
    // If already playing this station, toggle
    if (_currentStation?.stationUuid == station.stationUuid && isPlaying) {
      await pause();
      return;
    }

    _currentStation = station;
    _errorMessage = null;
    notifyListeners();

    onStationPlayed?.call(station);

    // Register click with API asynchronously in background
    unawaited(_apiService.registerStationClick(station.stationUuid));

    final streamUrl = station.streamUrl;
    if (streamUrl.isEmpty) {
      _errorMessage = 'No valid stream URL available for this station.';
      _status = AudioPlaybackStatus.error;
      notifyListeners();
      return;
    }

    await _audioService.playStream(streamUrl);
  }

  /// Toggle play / pause
  Future<void> togglePlayPause() async {
    if (_currentStation == null) return;
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentStation == null) return;
    if (_status == AudioPlaybackStatus.paused) {
      await _audioService.resume();
    } else {
      await playStation(_currentStation!);
    }
  }

  Future<void> retry() async {
    if (_currentStation != null) {
      await playStation(_currentStation!);
    }
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentStation = null;
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    _volume = val;
    await _audioService.setVolume(val);
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
