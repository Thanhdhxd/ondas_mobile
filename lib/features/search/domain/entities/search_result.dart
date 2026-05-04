import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class SearchResult extends Equatable {
  final String query;
  final int page;
  final int size;
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final List<SongSummary> songs;
  final List<ArtistSummary> artists;
  final List<AlbumSummary> albums;

  const SearchResult({
    required this.query,
    required this.page,
    required this.size,
    required this.totalSongs,
    required this.totalArtists,
    required this.totalAlbums,
    required this.songs,
    required this.artists,
    required this.albums,
  });

  @override
  List<Object?> get props => [
        query,
        page,
        size,
        totalSongs,
        totalArtists,
        totalAlbums,
        songs,
        artists,
        albums,
      ];
}
