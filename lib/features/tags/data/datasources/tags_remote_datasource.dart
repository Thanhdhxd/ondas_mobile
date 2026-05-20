import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/tags/data/models/tag_model.dart';

abstract class TagsRemoteDatasource {
  Future<List<TagModel>> getTags({String? type});

  Future<PageResult<TagModel>> searchTags({
    required String query,
    String mode = 'contains',
    int page = 0,
    int size = 20,
  });
}
