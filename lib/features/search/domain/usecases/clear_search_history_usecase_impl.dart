import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ondas_mobile/features/search/domain/usecases/clear_search_history_usecase.dart';

class ClearSearchHistoryUseCaseImpl implements ClearSearchHistoryUseCase {
  final SearchRepository _repository;

  const ClearSearchHistoryUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call() {
    return _repository.clearSearchHistory();
  }
}
