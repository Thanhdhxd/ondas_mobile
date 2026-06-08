import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/stats/domain/entities/listening_time_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_artist_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_song_stats.dart';

abstract class StatsRepository {
  Future<Either<Failure, ListeningTimeStats>> getListeningTime();
  Future<Either<Failure, List<TopSongStats>>> getTopSongs({int limit = 10});
  Future<Either<Failure, List<TopArtistStats>>> getTopArtists({int limit = 10});
}
