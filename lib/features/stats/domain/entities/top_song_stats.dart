import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class TopSongStats extends Equatable {
  final String id;
  final String title;
  final String? coverUrl;
  final int playCount;
  final List<ArtistRef> artists;

  const TopSongStats({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.playCount,
    required this.artists,
  });

  String get artistDisplay => artists.map((a) => a.name).join(', ');

  @override
  List<Object?> get props => [id, title, coverUrl, playCount, artists];
}
