import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/lyrics/domain/usecases/get_lyrics_usecase.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_state.dart';

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final GetLyricsUseCase _getLyricsUseCase;
  String? _currentSongId;

  LyricsBloc({required GetLyricsUseCase getLyricsUseCase})
      : _getLyricsUseCase = getLyricsUseCase,
        super(const LyricsInitial()) {
    on<LyricsRequested>(_onLyricsRequested);
    on<LyricsCleared>(_onLyricsCleared);
  }

  Future<void> _onLyricsRequested(
    LyricsRequested event,
    Emitter<LyricsState> emit,
  ) async {
    if (event.songId == _currentSongId && state is LyricsLoaded) return;

    _currentSongId = event.songId;
    emit(const LyricsLoading());

    final result = await _getLyricsUseCase(GetLyricsParams(songId: event.songId));
    await result.fold(
      (failure) async {
        if (failure is NotFoundFailure) {
          emit(const LyricsNotFound());
        } else {
          emit(LyricsFailure(message: failure.message));
        }
      },
      (lyrics) async => emit(LyricsLoaded(lyrics: lyrics)),
    );
  }

  void _onLyricsCleared(
    LyricsCleared event,
    Emitter<LyricsState> emit,
  ) {
    _currentSongId = null;
    emit(const LyricsInitial());
  }
}
