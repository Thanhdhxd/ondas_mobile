import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';

abstract class SearchUseCase {
  Future<Either<Failure, SearchResult>> call(SearchParams params);
}

class SearchParams {
  final String query;
  final int page;
  final int size;

  const SearchParams({
    required this.query,
    this.page = 0,
    this.size = 10,
  });
}
