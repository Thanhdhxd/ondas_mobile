import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/songs/domain/repositories/songs_repository.dart';
import 'package:ondas_mobile/features/songs/domain/usecases/get_songs_usecase.dart';

class GetSongsUseCaseImpl implements GetSongsUseCase {
  final SongsRepository _repository;

  const GetSongsUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, PageResult<SongSummary>>> call(GetSongsParams params) {
    return _repository.getSongs(
      artistId: params.artistId,
      albumId: params.albumId,
      page: params.page,
      size: params.size,
    );
  }
}
