import 'package:equatable/equatable.dart';

class PlaylistSongItem extends Equatable {
  final int position;
  final String songId;
  final String title;
  final String? coverUrl;
  final int durationSeconds;
  final String audioUrl;
  final List<String> artistNames;

  const PlaylistSongItem({
    required this.position,
    required this.songId,
    required this.title,
    this.coverUrl,
    required this.durationSeconds,
    this.audioUrl = '',
    this.artistNames = const <String>[],
  });

  String get durationDisplay {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  PlaylistSongItem copyWith({
    int? position,
    String? songId,
    String? title,
    String? coverUrl,
    int? durationSeconds,
    String? audioUrl,
    List<String>? artistNames,
  }) {
    return PlaylistSongItem(
      position: position ?? this.position,
      songId: songId ?? this.songId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      artistNames: artistNames ?? this.artistNames,
    );
  }

  @override
  List<Object?> get props =>
      [position, songId, title, coverUrl, durationSeconds, audioUrl, artistNames];
}
