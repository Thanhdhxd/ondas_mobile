import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player;

  final _statusController = StreamController<PlayerStatus>.broadcast();
  final _volumeController = StreamController<double>.broadcast();

  List<Song> _queue = [];
  int _currentIndex = 0;
  double _volume = 1.0;
  RepeatMode _repeatMode = RepeatMode.off;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingStateSub;

  AudioPlayerServiceImpl({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _playerStateSub = _player.playerStateStream.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState state) {
    if (state.processingState == ProcessingState.completed) {
      switch (_repeatMode) {
        case RepeatMode.one:
          _player.seek(Duration.zero).then((_) => _player.play());
        case RepeatMode.all:
          _currentIndex = (_currentIndex + 1) % _queue.length;
          _loadAndPlay(_queue[_currentIndex]);
        case RepeatMode.off:
          if (_currentIndex < _queue.length - 1) {
            _currentIndex++;
            _loadAndPlay(_queue[_currentIndex]);
          } else {
            _statusController.add(PlayerStatus.idle);
          }
      }
      return;
    }
    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) {
      _statusController.add(PlayerStatus.loading);
      return;
    }
    if (state.playing) {
      _statusController.add(PlayerStatus.playing);
    } else if (state.processingState == ProcessingState.ready) {
      _statusController.add(PlayerStatus.paused);
    }
  }

  Future<void> _loadAndPlay(Song song) async {
    try {
      _statusController.add(PlayerStatus.loading);
      await _player.setUrl(song.audioUrl);
      unawaited(_player.play());
    } catch (_) {
      _statusController.add(PlayerStatus.error);
    }
  }

  @override
  Stream<PlayerStatus> get statusStream => _statusController.stream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration> get durationStream =>
      _player.durationStream.where((d) => d != null).map((d) => d!);

  @override
  Stream<double> get volumeStream => _volumeController.stream;

  @override
  List<Song> get queue => List.unmodifiable(_queue);

  @override
  int get currentIndex => _currentIndex;

  @override
  Song? get currentSong =>
      _queue.isEmpty ? null : _queue[_currentIndex];

  @override
  Future<void> playSong({required List<Song> songs, required int index}) async {
    _queue = List.of(songs);
    _currentIndex = index.clamp(0, songs.length - 1);
    await _loadAndPlay(_queue[_currentIndex]);
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipPrevious() async {
    // If > 3s into song, restart; else go to previous
    final position = _player.position;
    if (position.inSeconds > 3 || _currentIndex == 0) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex--;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    _volumeController.add(_volume);
  }

  @override
  RepeatMode get repeatMode => _repeatMode;

  @override
  Future<void> setRepeatMode(RepeatMode mode) async {
    _repeatMode = mode;
  }

  @override
  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _processingStateSub?.cancel();
    await _statusController.close();
    await _volumeController.close();
    await _player.dispose();
  }
}
