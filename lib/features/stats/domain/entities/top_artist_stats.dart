import 'package:equatable/equatable.dart';

class TopArtistStats extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final int playCount;

  const TopArtistStats({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.playCount,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, playCount];
}
