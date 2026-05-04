import 'package:equatable/equatable.dart';

class PlaylistSummary extends Equatable {
  final String id;
  final String name;
  final String? coverUrl;
  final int totalSongs;
  final bool containsSong;

  const PlaylistSummary({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.totalSongs,
    required this.containsSong,
  });

  PlaylistSummary copyWith({
    String? id,
    String? name,
    String? coverUrl,
    int? totalSongs,
    bool? containsSong,
  }) {
    return PlaylistSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      totalSongs: totalSongs ?? this.totalSongs,
      containsSong: containsSong ?? this.containsSong,
    );
  }

  @override
  List<Object?> get props => [id, name, coverUrl, totalSongs, containsSong];
}
