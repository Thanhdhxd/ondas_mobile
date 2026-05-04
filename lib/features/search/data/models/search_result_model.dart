import 'package:ondas_mobile/features/home/data/models/album_summary_model.dart';
import 'package:ondas_mobile/features/home/data/models/artist_summary_model.dart';
import 'package:ondas_mobile/features/home/data/models/song_summary_model.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.query,
    required super.page,
    required super.size,
    required super.totalSongs,
    required super.totalArtists,
    required super.totalAlbums,
    required super.songs,
    required super.artists,
    required super.albums,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      query: (json['query'] as String?) ?? '',
      page: json['page'] as int,
      size: json['size'] as int,
      totalSongs: json['totalSongs'] as int,
      totalArtists: json['totalArtists'] as int,
      totalAlbums: json['totalAlbums'] as int,
      songs: (json['songs'] as List<dynamic>)
          .map((e) => SongSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      albums: (json['albums'] as List<dynamic>)
          .map((e) => AlbumSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
