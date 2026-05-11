import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';

sealed class LyricsState extends Equatable {
  const LyricsState();

  @override
  List<Object?> get props => [];
}

class LyricsInitial extends LyricsState {
  const LyricsInitial();
}

class LyricsLoading extends LyricsState {
  const LyricsLoading();
}

class LyricsLoaded extends LyricsState {
  final Lyrics lyrics;

  const LyricsLoaded({required this.lyrics});

  @override
  List<Object?> get props => [lyrics];
}

class LyricsNotFound extends LyricsState {
  const LyricsNotFound();
}

class LyricsFailure extends LyricsState {
  final String message;

  const LyricsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
