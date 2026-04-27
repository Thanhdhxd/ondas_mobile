import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/pause_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/resume_usecase.dart';
import 'package:ondas_mobile/features/player/domain/usecases/seek_usecase.dart';
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
  final AudioPlayerService _service;

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
    required AudioPlayerService audioPlayerService,
  })  : _playSong = playSongUseCase,
        _pause = pauseUseCase,
        _resume = resumeUseCase,
        _seek = seekUseCase,
        _skipNext = skipNextUseCase,
        _skipPrevious = skipPreviousUseCase,
        _setVolume = setVolumeUseCase,
        _service = audioPlayerService,
        super(const PlayerState()) {
    on<PlaySongRequested>(_onPlaySongRequested);
    on<PauseRequested>(_onPauseRequested);
    on<ResumeRequested>(_onResumeRequested);
    on<SeekRequested>(_onSeekRequested);
    on<SkipNextRequested>(_onSkipNextRequested);
    on<SkipPreviousRequested>(_onSkipPreviousRequested);
    on<VolumeChanged>(_onVolumeChanged);
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
    emit(state.copyWith(
      status: PlayerStatus.loading,
      queue: event.songs,
      currentIndex: event.index,
      currentSong: event.songs[event.index],
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    ));
    await _playSong(songs: event.songs, index: event.index);
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

  void _onStatusUpdated(PlayerStatusUpdated event, Emitter<PlayerState> emit) {
    final status = event.status as PlayerStatus;
    if (status == PlayerStatus.idle) {
      emit(state.copyWith(status: PlayerStatus.idle, clearCurrentSong: true));
    } else {
      // Sync currentSong from service (may have advanced due to auto-next)
      emit(state.copyWith(
        status: status,
        currentSong: _service.currentSong,
        currentIndex: _service.currentIndex,
      ));
    }
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
    await _service.dispose();
    return super.close();
  }
}
