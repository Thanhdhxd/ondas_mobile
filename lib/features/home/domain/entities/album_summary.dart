import 'package:equatable/equatable.dart';

class AlbumSummary extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String? coverUrl;
  final String? releaseDate;
  final String? albumType;
  final int totalTracks;
  final List<String> artistIds;

  const AlbumSummary({
    required this.id,
    required this.title,
    required this.slug,
    this.coverUrl,
    this.releaseDate,
    this.albumType,
    required this.totalTracks,
    required this.artistIds,
  });

  @override
  List<Object?> get props => [id, title, slug, coverUrl, releaseDate, albumType, totalTracks, artistIds];
}
