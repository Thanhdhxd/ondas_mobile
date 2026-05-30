import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/record_play_history_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_repeat_mode_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/set_volume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_next_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/skip_previous_usecase.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlaySongUseCase _playSong;
  final PauseUseCase _pause;
  final ResumeUseCase _resume;
  final SeekUseCase _seek;
  final SkipNextUseCase _skipNext;
  final SkipPreviousUseCase _skipPrevious;
  final SetVolumeUseCase _setVolume;
  final SetRepeatModeUseCase _setRepeatMode;
  final AudioPlayerService _service;
  final RecordPlayHistoryUseCase _recordPlayHistory;

  StreamSubscription<dynamic>? _statusSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<double>? _volumeSub;

  PlayerBloc({
    required PlaySongUseCase playSongUseCase,
    required PauseUseCase pauseUseCase,
    required ResumeUseCase resumeUseCase,
    required SeekUseCase seekUseCase,
    required SkipNextUseCase skipNextUseCase,
    required SkipPreviousUseCase skipPreviousUseCase,
    required SetVolumeUseCase setVolumeUseCase,
    required SetRepeatModeUseCase setRepeatModeUseCase,
    required AudioPlayerService audioPlayerService,
    required RecordPlayHistoryUseCase recordPlayHistoryUseCase,
  })  : _playSong = playSongUseCase,
        _pause = pauseUseCase,
        _resume = resumeUseCase,
        _seek = seekUseCase,
        _skipNext = skipNextUseCase,
        _skipPrevious = skipPreviousUseCase,
        _setVolume = setVolumeUseCase,
        _setRepeatMode = setRepeatModeUseCase,
        _service = audioPlayerService,
        _recordPlayHistory = recordPlayHistoryUseCase,
        super(const PlayerState()) {
    on<PlaySongRequested>(_onPlaySongRequested);
    on<PauseRequested>(_onPauseRequested);
    on<ResumeRequested>(_onResumeRequested);
    on<SeekRequested>(_onSeekRequested);
    on<SkipNextRequested>(_onSkipNextRequested);
    on<SkipPreviousRequested>(_onSkipPreviousRequested);
    on<VolumeChanged>(_onVolumeChanged);
    on<RepeatModeToggled>(_onRepeatModeToggled);
    on<PlayerStatusUpdated>(_onStatusUpdated);
    on<PlayerPositionUpdated>(_onPositionUpdated);
    on<PlayerDurationUpdated>(_onDurationUpdated);
    on<PlayerVolumeUpdated>(_onVolumeUpdated);

    _subscribeToService();
  }

  void _subscribeToService() {
    _statusSub = _service.statusStream.listen(
      (status) => add(PlayerStatusUpdated(status)),
    );
    _positionSub = _service.positionStream.listen(
      (position) => add(PlayerPositionUpdated(position)),
    );
    _durationSub = _service.durationStream.listen(
      (duration) => add(PlayerDurationUpdated(duration)),
    );
    _volumeSub = _service.volumeStream.listen(
      (volume) => add(PlayerVolumeUpdated(volume)),
    );
  }

  Future<void> _onPlaySongRequested(
    PlaySongRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.songs.isEmpty) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'Danh sách phát rỗng.',
      ));
      return;
    }
    final index = event.index.clamp(0, event.songs.length - 1);
    final song = event.songs[index];

    emit(state.copyWith(
      status: PlayerStatus.loading,
      queue: event.songs,
      currentIndex: index,
      currentSong: song,
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    ));

    try {
      await _playSong(songs: event.songs, index: index);
      final songId = song.id;
      _recordPlayHistory(songId: songId, source: event.source).ignore();
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: cleanMsg,
      ));
    }
  }

  Future<void> _onPauseRequested(
    PauseRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await _pause();
  }

  Future<void> _onResumeRequested(
    ResumeRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await _resume();
  }

  Future<void> _onSeekRequested(
    SeekRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await _seek(event.position);
  }

  Future<void> _onSkipNextRequested(
    SkipNextRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.queue.length) {
      emit(state.copyWith(
        status: PlayerStatus.loading,
        currentIndex: nextIndex,
        currentSong: state.queue[nextIndex],
        position: Duration.zero,
        duration: Duration.zero,
      ));
    }
    await _skipNext();
  }

  Future<void> _onSkipPreviousRequested(
    SkipPreviousRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.position.inSeconds <= 3 && state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      emit(state.copyWith(
        status: PlayerStatus.loading,
        currentIndex: prevIndex,
        currentSong: state.queue[prevIndex],
        position: Duration.zero,
        duration: Duration.zero,
      ));
    } else {
      emit(state.copyWith(position: Duration.zero));
    }
    await _skipPrevious();
  }

  Future<void> _onVolumeChanged(
    VolumeChanged event,
    Emitter<PlayerState> emit,
  ) async {
    await _setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onRepeatModeToggled(
    RepeatModeToggled event,
    Emitter<PlayerState> emit,
  ) async {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await _setRepeatMode(next);
    emit(state.copyWith(repeatMode: next));
  }

  void _onStatusUpdated(PlayerStatusUpdated event, Emitter<PlayerState> emit) {
    final status = event.status as PlayerStatus;
    if (status == PlayerStatus.idle) {
      if (state.status == PlayerStatus.error) return;
      emit(state.copyWith(status: PlayerStatus.idle, clearCurrentSong: true));
      return;
    }

    final serviceSong = _service.currentSong;
    var nextIndex = state.currentIndex;
    // While switching tracks, keep the index chosen by PlaySongRequested. Stale
    // audio status events can still report the previous track/index briefly.
    if (state.status != PlayerStatus.loading) {
      if (serviceSong != null && state.queue.isNotEmpty) {
        final byId = state.queue.indexWhere((s) => s.id == serviceSong.id);
        nextIndex = byId >= 0 ? byId : _service.currentIndex;
      } else {
        nextIndex = _service.currentIndex;
      }
    }

    emit(state.copyWith(
      status: status,
      currentSong: serviceSong ?? state.currentSong,
      currentIndex: nextIndex,
    ));
  }

  void _onPositionUpdated(PlayerPositionUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationUpdated(PlayerDurationUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onVolumeUpdated(PlayerVolumeUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(volume: event.volume));
  }

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _volumeSub?.cancel();
    // Do NOT call _service.dispose() here: AudioPlayerService is a lazy
    // singleton whose lifetime spans the entire app session. Disposing it
    // from a factory BLoC would permanently destroy the shared stream
    // controllers, breaking every subsequent screen / test that needs audio.
    return super.close();
  }
}
