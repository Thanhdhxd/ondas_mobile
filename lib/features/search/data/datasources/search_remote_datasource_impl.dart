import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/search/data/datasources/search_remote_datasource.dart';
import 'package:ondas_mobile/features/search/data/models/search_result_model.dart';
import 'package:ondas_mobile/features/search/data/models/search_suggestion_model.dart';

class SearchRemoteDatasourceImpl implements SearchRemoteDatasource {
  final DioClient _dioClient;

  const SearchRemoteDatasourceImpl(this._dioClient);

  @override
  Future<SearchResultModel> search({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.search,
      queryParameters: {
        'query': query,
        'page': page,
        'size': size,
      },
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => SearchResultModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<SearchSuggestionModel> getSuggestions() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.searchSuggestions,
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => SearchSuggestionModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<void> clearHistory() async {
    await _dioClient.delete<void>(ApiConstants.searchHistory);
  }
}
