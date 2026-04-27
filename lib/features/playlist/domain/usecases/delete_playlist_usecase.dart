import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class DeletePlaylistUseCase {
  Future<Either<Failure, void>> call(String id);
}
