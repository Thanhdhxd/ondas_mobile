import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchResult>> search({
    required String query,
    int page = 0,
    int size = 10,
  });

  Future<Either<Failure, SearchSuggestion>> getSuggestions();

  Future<Either<Failure, void>> clearSearchHistory();
}
