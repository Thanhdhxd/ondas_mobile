import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/stats/domain/entities/listening_time_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_artist_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_song_stats.dart';

enum StatsStatus { initial, loading, loaded, error }

class StatsState extends Equatable {
  final StatsStatus status;
  final ListeningTimeStats? listeningTime;
  final List<TopSongStats> topSongs;
  final List<TopArtistStats> topArtists;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.listeningTime,
    this.topSongs = const [],
    this.topArtists = const [],
    this.errorMessage,
  });

  StatsState copyWith({
    StatsStatus? status,
    ListeningTimeStats? listeningTime,
    List<TopSongStats>? topSongs,
    List<TopArtistStats>? topArtists,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      listeningTime: listeningTime ?? this.listeningTime,
      topSongs: topSongs ?? this.topSongs,
      topArtists: topArtists ?? this.topArtists,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        listeningTime,
        topSongs,
        topArtists,
        errorMessage,
      ];
}
