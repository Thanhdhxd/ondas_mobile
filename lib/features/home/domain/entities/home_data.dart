import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class HomeData extends Equatable {
  final List<SongSummary> trendingSongs;
  final List<ArtistSummary> featuredArtists;
  final List<AlbumSummary> newReleases;

  const HomeData({
    required this.trendingSongs,
    required this.featuredArtists,
    required this.newReleases,
  });

  @override
  List<Object?> get props => [trendingSongs, featuredArtists, newReleases];
}
