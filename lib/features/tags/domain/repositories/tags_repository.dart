import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';

abstract class TagsRepository {
  Future<Either<Failure, List<Tag>>> getTags({String? type});

  Future<Either<Failure, PageResult<Tag>>> searchTags({
    required String query,
    String mode = 'contains',
    int page = 0,
    int size = 20,
  });
}
