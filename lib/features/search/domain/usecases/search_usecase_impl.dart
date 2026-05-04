import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';

class SearchUseCaseImpl implements SearchUseCase {
  final SearchRepository _repository;

  const SearchUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, SearchResult>> call(SearchParams params) {
    return _repository.search(
      query: params.query,
      page: params.page,
      size: params.size,
    );
  }
}
