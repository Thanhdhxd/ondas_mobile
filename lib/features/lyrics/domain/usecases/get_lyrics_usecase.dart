import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';

abstract class GetLyricsUseCase {
  Future<Either<Failure, Lyrics>> call(GetLyricsParams params);
}

class GetLyricsParams {
  final String songId;

  const GetLyricsParams({required this.songId});
}
