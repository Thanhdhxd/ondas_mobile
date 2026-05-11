import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';

abstract class LyricsRepository {
  Future<Either<Failure, Lyrics>> getLyrics(String songId);
}
