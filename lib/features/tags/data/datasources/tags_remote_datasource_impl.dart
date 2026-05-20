import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/tags/data/datasources/tags_remote_datasource.dart';
import 'package:ondas_mobile/features/tags/data/models/tag_model.dart';

class TagsRemoteDatasourceImpl implements TagsRemoteDatasource {
  final DioClient _dioClient;

  const TagsRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<TagModel>> getTags({String? type}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.tags,
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? [];
  }

  @override
  Future<PageResult<TagModel>> searchTags({
    required String query,
    String mode = 'contains',
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.tagsSearch,
      queryParameters: {
        'query': query,
        'mode': mode,
        'page': page,
        'size': size,
      },
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (item) => TagModel.fromJson(item),
      ),
    );
    return apiResponse.data!;
  }
}
