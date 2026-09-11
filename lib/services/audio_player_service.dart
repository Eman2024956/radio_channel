import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioPlaybackStatus {
  idle,
  buffering,
  playing,
  paused,
  error,
}

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  AudioPlaybackStatus _status = AudioPlaybackStatus.idle;
  String? _errorMessage;
  double _volume = 1.0;
  String? _currentUrl;

  final _statusController = StreamController<AudioPlaybackStatus>.broadcast();
  Stream<AudioPlaybackStatus> get statusStream => _statusController.stream;
  AudioPlaybackStatus get currentStatus => _status;
  String? get errorMessage => _errorMessage;
  double get volume => _volume;
  String? get currentUrl => _currentUrl;

  void _init() {
    // Configure audio context if applicable
    _player.onPlayerStateChanged.listen((PlayerState state) {
      switch (state) {
        case PlayerState.playing:
          _setStatus(AudioPlaybackStatus.playing);
          break;
        case PlayerState.paused:
          _setStatus(AudioPlaybackStatus.paused);
          break;
        case PlayerState.stopped:
        case PlayerState.completed:
          _setStatus(AudioPlaybackStatus.idle);
          break;
        case PlayerState.disposed:
          _setStatus(AudioPlaybackStatus.idle);
          break;
      }
    });

    _player.onLog.listen((msg) {
      if (msg.toLowerCase().contains('error') || msg.toLowerCase().contains('failed')) {
        debugPrint('AudioPlayer log: $msg');
      }
    });
  }

  void _setStatus(AudioPlaybackStatus newStatus, [String? err]) {
    _status = newStatus;
    _errorMessage = err;
    _statusController.add(_status);
  }

  /// Play audio stream from URL
  Future<void> playStream(String url) async {
    try {
      _currentUrl = url;
      _errorMessage = null;
      _setStatus(AudioPlaybackStatus.buffering);

      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(_volume);

      final cleanUrl = url.trim();
      await _player.play(UrlSource(cleanUrl));
    } catch (e) {
      debugPrint('Error playing stream: $e');
      _setStatus(AudioPlaybackStatus.error, 'Unable to play stream. Station may be temporarily offline.');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      if (_currentUrl != null && _status == AudioPlaybackStatus.paused) {
        await _player.resume();
      } else if (_currentUrl != null) {
        await playStream(_currentUrl!);
      }
    } catch (e) {
      _setStatus(AudioPlaybackStatus.error, 'Failed to resume: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      _setStatus(AudioPlaybackStatus.paused);
    } catch (e) {
      debugPrint('Error pausing stream: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _player.stop();
      _setStatus(AudioPlaybackStatus.idle);
    } catch (e) {
      debugPrint('Error stopping stream: $e');
    }
  }

  /// Set player volume (0.0 to 1.0)
  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  void dispose() {
    _statusController.close();
    _player.dispose();
  }
}
