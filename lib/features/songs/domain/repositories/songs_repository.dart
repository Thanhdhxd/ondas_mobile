import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

abstract class SongsRepository {
  Future<Either<Failure, PageResult<SongSummary>>> getSongs({
    String? artistId,
    String? albumId,
    int page = 0,
    int size = 20,
  });
}
