import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ondas_mobile/features/search/domain/usecases/get_search_suggestions_usecase.dart';

class GetSearchSuggestionsUseCaseImpl implements GetSearchSuggestionsUseCase {
  final SearchRepository _repository;

  const GetSearchSuggestionsUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, SearchSuggestion>> call() {
    return _repository.getSuggestions();
  }
}
