import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';

class AlbumSummaryModel extends AlbumSummary {
  const AlbumSummaryModel({
    required super.id,
    required super.title,
    required super.slug,
    super.coverUrl,
    super.releaseDate,
    super.albumType,
    required super.totalTracks,
    required super.artistIds,
  });

  factory AlbumSummaryModel.fromJson(Map<String, dynamic> json) {
    return AlbumSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      releaseDate: json['releaseDate'] as String?,
      albumType: json['albumType'] as String?,
      totalTracks: json['totalTracks'] as int,
      artistIds: (json['artistIds'] as List<dynamic>).cast<String>(),
    );
  }
}
