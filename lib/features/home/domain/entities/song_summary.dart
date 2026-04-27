import 'package:equatable/equatable.dart';

class ArtistRef extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;

  const ArtistRef({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

class GenreRef extends Equatable {
  final int id;
  final String name;

  const GenreRef({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SongSummary extends Equatable {
  final String id;
  final String title;
  final String slug;
  final int durationSeconds;
  final String audioUrl;
  final String? coverUrl;
  final int playCount;
  final bool active;
  final List<ArtistRef> artists;
  final List<GenreRef> genres;

  const SongSummary({
    required this.id,
    required this.title,
    required this.slug,
    required this.durationSeconds,
    required this.audioUrl,
    this.coverUrl,
    required this.playCount,
    required this.active,
    required this.artists,
    required this.genres,
  });

  @override
  List<Object?> get props => [id, title, slug, durationSeconds, audioUrl, coverUrl, playCount, active, artists, genres];
}
