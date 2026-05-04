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
  final int page;
  final int size;

  const GetSongsParams({
    this.artistId,
    this.albumId,
    this.page = 0,
    this.size = 20,
  }) : assert(artistId != null || albumId != null,
            'Either artistId or albumId must be provided');
}
