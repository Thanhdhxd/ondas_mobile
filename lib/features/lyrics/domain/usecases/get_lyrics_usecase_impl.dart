import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';
import 'package:ondas_mobile/features/lyrics/domain/repositories/lyrics_repository.dart';
import 'package:ondas_mobile/features/lyrics/domain/usecases/get_lyrics_usecase.dart';

class GetLyricsUseCaseImpl implements GetLyricsUseCase {
  final LyricsRepository _repository;

  const GetLyricsUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, Lyrics>> call(GetLyricsParams params) {
    return _repository.getLyrics(params.songId);
  }
}
