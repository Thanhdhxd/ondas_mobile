import 'package:equatable/equatable.dart';

class PlayHistorySong extends Equatable {
  final String id;
  final String title;
  final String? coverUrl;
  final int durationSeconds;
  final String audioUrl;

  const PlayHistorySong({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.durationSeconds,
    required this.audioUrl,
  });

  @override
  List<Object?> get props => [id, title, coverUrl, durationSeconds, audioUrl];
}

class PlayHistoryItem extends Equatable {
  final int id;
  final PlayHistorySong song;
  final DateTime playedAt;
  final String? source;

  const PlayHistoryItem({
    required this.id,
    required this.song,
    required this.playedAt,
    this.source,
  });

  @override
  List<Object?> get props => [id, song, playedAt, source];
}
