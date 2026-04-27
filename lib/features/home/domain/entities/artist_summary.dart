import 'package:equatable/equatable.dart';

class ArtistSummary extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? bio;
  final String? avatarUrl;
  final String? country;

  const ArtistSummary({
    required this.id,
    required this.name,
    required this.slug,
    this.bio,
    this.avatarUrl,
    this.country,
  });

  @override
  List<Object?> get props => [id, name, slug, bio, avatarUrl, country];
}
