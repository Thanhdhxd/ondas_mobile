import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase.dart';

class ClearPlayHistoryUseCaseImpl implements ClearPlayHistoryUseCase {
  final ProfileRepository _repository;

  const ClearPlayHistoryUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call() {
    return _repository.clearPlayHistory();
  }
}
