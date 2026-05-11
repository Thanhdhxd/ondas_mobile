import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

abstract class GetSongsUseCase {
  Future<Either<Failure, PageResult<SongSummary>>> call(GetSongsParams params);
}

class GetSongsParams {
  final String? artistId;
  final String? albumId;
  final int? genreId;
  final int page;
  final int size;

  const GetSongsParams({
    this.artistId,
    this.albumId,
    this.genreId,
    this.page = 0,
    this.size = 20,
  }) : assert(artistId != null || albumId != null || genreId != null,
            'At least one filter (artistId, albumId, or genreId) must be provided');
}
