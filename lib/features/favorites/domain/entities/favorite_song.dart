import 'package:equatable/equatable.dart';

class FavoriteSong extends Equatable {
  final String id;
  final String title;
  final String? coverUrl;
  final String audioUrl;
  final int durationSeconds;
  final List<String> artistNames;

  const FavoriteSong({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.audioUrl,
    required this.durationSeconds,
    required this.artistNames,
  });

  String get artistDisplay => artistNames.join(', ');

  @override
  List<Object?> get props => [id, title, coverUrl, audioUrl, durationSeconds, artistNames];
}

class FavoriteItem extends Equatable {
  final String id;
  final FavoriteSong song;
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    required this.song,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [id, song, addedAt];
}
