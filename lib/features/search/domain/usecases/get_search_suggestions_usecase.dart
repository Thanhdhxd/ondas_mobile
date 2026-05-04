import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';

abstract class GetSearchSuggestionsUseCase {
  Future<Either<Failure, SearchSuggestion>> call();
}
