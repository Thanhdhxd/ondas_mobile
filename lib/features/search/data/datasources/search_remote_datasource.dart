import 'package:ondas_mobile/features/search/data/models/search_result_model.dart';
import 'package:ondas_mobile/features/search/data/models/search_suggestion_model.dart';

abstract class SearchRemoteDatasource {
  Future<SearchResultModel> search({
    required String query,
    int page = 0,
    int size = 10,
  });

  Future<SearchSuggestionModel> getSuggestions();

  Future<void> clearHistory();
}
