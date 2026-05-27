import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/features/player/data/services/audio_player_service_impl.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';

Future<AudioPlayerService> initAudioPlayerService() async {
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  if (!isAndroid) {
    return AudioPlayerServiceImpl();
  }

  final handler = await AudioService.init(
    builder: () => OndasAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: AppConstants.playerNotificationChannelId,
      androidNotificationChannelName:
          AppConstants.playerNotificationChannelName,
      androidNotificationChannelDescription:
          AppConstants.playerNotificationChannelDescription,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: false,
    ),
  );

  return AudioServicePlayerServiceImpl(handler);
}

class AudioServicePlayerServiceImpl implements AudioPlayerService {
  final AudioHandler _handler;
  final StreamController<PlayerStatus> _statusController =
      StreamController<PlayerStatus>.broadcast();
  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();

  List<Song> _queue = [];
  int _currentIndex = 0;
  Song? _currentSong;
  RepeatMode _repeatMode = RepeatMode.off;

  StreamSubscription<List<MediaItem>>? _queueSub;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;

  AudioServicePlayerServiceImpl(this._handler) {
    _queueSub = _handler.queue.listen(_onQueueUpdated);
    _playbackSub = _handler.playbackState.listen(_onPlaybackState);
    _mediaItemSub = _handler.mediaItem.listen(_onMediaItem);
  }

  @override
  Stream<PlayerStatus> get statusStream => _statusController.stream;

  @override
  Stream<Duration> get positionStream => AudioService.position;

  @override
  Stream<Duration> get durationStream => _handler.mediaItem
      .where((item) => item?.duration != null)
      .map((item) => item!.duration!);

  @override
  Stream<double> get volumeStream => _volumeController.stream;

  @override
  List<Song> get queue => List.unmodifiable(_queue);

  @override
  int get currentIndex => _currentIndex;

  @override
  Song? get currentSong => _currentSong;

  @override
  Future<void> playSong({required List<Song> songs, required int index}) async {
    final songMaps = songs.map(_songToMap).toList();
    await _handler.customAction(
      'playSong',
      {'songs': songMaps, 'index': index},
    );
  }

  @override
  Future<void> pause() => _handler.pause();

  @override
  Future<void> resume() => _handler.play();

  @override
  Future<void> seek(Duration position) => _handler.seek(position);

  @override
  Future<void> skipNext() => _handler.skipToNext();

  @override
  Future<void> skipPrevious() => _handler.skipToPrevious();

  @override
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _volumeController.add(clamped);
    await _handler.customAction('setVolume', {'volume': clamped});
  }

  @override
  RepeatMode get repeatMode => _repeatMode;

  @override
  Future<void> setRepeatMode(RepeatMode mode) async {
    _repeatMode = mode;
    await _handler.setRepeatMode(_toAudioServiceRepeatMode(mode));
  }

  @override
  Future<void> dispose() async {
    await _queueSub?.cancel();
    await _playbackSub?.cancel();
    await _mediaItemSub?.cancel();
    await _statusController.close();
    await _volumeController.close();
    await _handler.customAction('dispose');
  }

  void _onQueueUpdated(List<MediaItem> items) {
    _queue = items.map(_songFromMediaItem).toList();
    _syncCurrentSong();
  }

  void _onMediaItem(MediaItem? item) {
    if (item == null) {
      return;
    }
    _currentSong = _songFromMediaItem(item);
  }

  void _onPlaybackState(PlaybackState state) {
    if (state.queueIndex != null) {
      _currentIndex = state.queueIndex!;
    }
    _syncCurrentSong();
    _statusController.add(_mapStatus(state));
  }

  void _syncCurrentSong() {
    if (_queue.isEmpty) {
      return;
    }
    if (_currentIndex < 0 || _currentIndex >= _queue.length) {
      _currentIndex = 0;
    }
    _currentSong = _queue[_currentIndex];
  }

  PlayerStatus _mapStatus(PlaybackState state) {
    return switch (state.processingState) {
      AudioProcessingState.idle => PlayerStatus.idle,
      AudioProcessingState.loading => PlayerStatus.loading,
      AudioProcessingState.buffering => PlayerStatus.loading,
      AudioProcessingState.ready =>
        state.playing ? PlayerStatus.playing : PlayerStatus.paused,
      AudioProcessingState.completed =>
        _queue.isEmpty
            ? PlayerStatus.idle
            : _repeatMode == RepeatMode.off && _currentIndex >= _queue.length - 1
                ? PlayerStatus.idle
                : PlayerStatus.loading,
      AudioProcessingState.error => PlayerStatus.error,
    };
  }

  AudioServiceRepeatMode _toAudioServiceRepeatMode(RepeatMode mode) {
    return switch (mode) {
      RepeatMode.off => AudioServiceRepeatMode.none,
      RepeatMode.all => AudioServiceRepeatMode.all,
      RepeatMode.one => AudioServiceRepeatMode.one,
    };
  }

  Song _songFromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};
    final artistNames = _listOfStrings(extras['artistNames']);
    final audioUrl = extras['audioUrl'] as String? ?? '';
    final coverUrl = extras['coverUrl'] as String?;
    final durationSeconds =
        _intFromValue(extras['durationSeconds']) ??
        item.duration?.inSeconds ??
        0;

    return Song(
      id: item.id,
      title: item.title,
      artistNames: artistNames.isEmpty && item.artist != null
          ? item.artist!.split(', ')
          : artistNames,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
    );
  }

  Map<String, dynamic> _songToMap(Song song) {
    return {
      'id': song.id,
      'title': song.title,
      'artistNames': song.artistNames,
      'coverUrl': song.coverUrl,
      'audioUrl': song.audioUrl,
      'durationSeconds': song.durationSeconds,
    };
  }

  List<String> _listOfStrings(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  int? _intFromValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}

class OndasAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = 0;
  //ignore: unused_field
  RepeatMode _repeatMode = RepeatMode.off;
  MediaItem? _currentMediaItem;

  StreamSubscription<int?>? _indexSub;
  StreamSubscription<Duration?>? _durationSub;

  OndasAudioHandler() {
    _indexSub = _player.currentIndexStream.listen(_onIndexChanged);
    _durationSub = _player.durationStream.listen(_onDurationChanged);
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playSong({required List<Song> songs, required int index}) async {
    _queue = List.of(songs);
    _currentIndex = index.clamp(0, songs.length - 1);

    final mediaItems = _queue.map(_songToMediaItem).toList();
    queue.add(mediaItems);

    final playlist = ConcatenatingAudioSource(
      children: _queue
          .map((song) => AudioSource.uri(Uri.parse(song.audioUrl)))
          .toList(),
    );

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: _currentIndex,
        initialPosition: Duration.zero,
      );
      _setMediaItem(mediaItems[_currentIndex]);
      await _player.play();
    } catch (_) {
      await _player.stop();
      return;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async {
    final position = _player.position;
    if (position.inSeconds > 3 || _currentIndex == 0) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final mapped = switch (repeatMode) {
      AudioServiceRepeatMode.none => RepeatMode.off,
      AudioServiceRepeatMode.all => RepeatMode.all,
      AudioServiceRepeatMode.one => RepeatMode.one,
      _ => RepeatMode.off,
    };
    _repeatMode = mapped;
    final loopMode = switch (mapped) {
      RepeatMode.off => LoopMode.off,
      RepeatMode.all => LoopMode.all,
      RepeatMode.one => LoopMode.one,
    };
    await _player.setLoopMode(loopMode);
    await super.setRepeatMode(repeatMode);
  }

  @override
  Future<dynamic> customAction(
    String name,
    [Map<String, dynamic>? extras]
  ) async {
    switch (name) {
      case 'playSong':
        final songsData = (extras?['songs'] as List<dynamic>? ?? const []);
        final indexValue = extras?['index'];
        final index = indexValue is num ? indexValue.toInt() : 0;
        final songs = songsData
            .map((data) => _songFromMap(data))
            .whereType<Song>()
            .toList();
        await playSong(songs: songs, index: index);
        return true;
      case 'setVolume':
        final volumeValue = extras?['volume'];
        final volume = volumeValue is num ? volumeValue.toDouble() : null;
        if (volume != null) {
          await setVolume(volume);
        }
        return true;
      case 'dispose':
        await dispose();
        return true;
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  Future<void> dispose() async {
    await _indexSub?.cancel();
    await _durationSub?.cancel();
    await _player.dispose();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final controls = <MediaControl>[
      MediaControl.skipToPrevious,
      if (_player.playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];

    return PlaybackState(
      controls: controls,
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(event.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }


  void _onIndexChanged(int? index) {
    if (index == null || index < 0 || index >= _queue.length) {
      return;
    }
    _currentIndex = index;
    _setMediaItem(_songToMediaItem(_queue[_currentIndex]));
  }

  void _onDurationChanged(Duration? duration) {
    if (duration == null || _currentMediaItem == null) {
      return;
    }
    if (_currentMediaItem!.duration == duration) {
      return;
    }
    _setMediaItem(_currentMediaItem!.copyWith(duration: duration));
  }

  void _setMediaItem(MediaItem item) {
    _currentMediaItem = item;
    mediaItem.add(item);
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artistDisplay,
      artUri: _parseUri(song.coverUrl),
      duration: song.duration,
      extras: {
        'audioUrl': song.audioUrl,
        'artistNames': song.artistNames,
        'coverUrl': song.coverUrl,
        'durationSeconds': song.durationSeconds,
      },
    );
  }

  Song? _songFromMap(dynamic data) {
    if (data is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final artistNames = map['artistNames'] is List
        ? (map['artistNames'] as List).whereType<String>().toList()
        : const <String>[];
    final durationValue = map['durationSeconds'];
    final durationSeconds = durationValue is num ? durationValue.toInt() : 0;

    return Song(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      artistNames: artistNames,
      coverUrl: map['coverUrl'] as String?,
      audioUrl: map['audioUrl'] as String? ?? '',
      durationSeconds: durationSeconds,
    );
  }

  Uri? _parseUri(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return Uri.tryParse(value);
  }
}
