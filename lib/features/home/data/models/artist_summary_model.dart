import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';

class ArtistSummaryModel extends ArtistSummary {
  const ArtistSummaryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.bio,
    super.avatarUrl,
    super.country,
  });

  factory ArtistSummaryModel.fromJson(Map<String, dynamic> json) {
    return ArtistSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      bio: json['bio'] as String?,
      avatarUrl: ApiConstants.resolveUrl(json['avatarUrl'] as String?),
      country: json['country'] as String?,
    );
  }
}
