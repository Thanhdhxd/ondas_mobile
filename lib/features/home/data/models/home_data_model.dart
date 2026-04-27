import 'package:ondas_mobile/features/home/data/models/album_summary_model.dart';
import 'package:ondas_mobile/features/home/data/models/artist_summary_model.dart';
import 'package:ondas_mobile/features/home/data/models/song_summary_model.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';

class HomeDataModel extends HomeData {
  const HomeDataModel({
    required super.trendingSongs,
    required super.featuredArtists,
    required super.newReleases,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      trendingSongs: (json['trendingSongs'] as List<dynamic>)
          .map((e) => SongSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredArtists: (json['featuredArtists'] as List<dynamic>)
          .map((e) => ArtistSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      newReleases: (json['newReleases'] as List<dynamic>)
          .map((e) => AlbumSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
