import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final List<String> artistNames;
  final String? coverUrl;
  final String audioUrl;
  final int durationSeconds;

  const Song({
    required this.id,
    required this.title,
    required this.artistNames,
    this.coverUrl,
    required this.audioUrl,
    required this.durationSeconds,
  });

  String get artistDisplay => artistNames.join(', ');

  Duration get duration => Duration(seconds: durationSeconds);

  @override
  List<Object?> get props => [id, title, artistNames, coverUrl, audioUrl, durationSeconds];
}
