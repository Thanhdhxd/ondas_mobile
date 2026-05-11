import 'package:equatable/equatable.dart';

sealed class LyricsEvent extends Equatable {
  const LyricsEvent();

  @override
  List<Object?> get props => [];
}

class LyricsRequested extends LyricsEvent {
  final String songId;

  const LyricsRequested(this.songId);

  @override
  List<Object?> get props => [songId];
}

class LyricsCleared extends LyricsEvent {
  const LyricsCleared();
}
