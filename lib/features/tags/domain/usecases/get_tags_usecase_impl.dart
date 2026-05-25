import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';
import 'package:ondas_mobile/features/tags/domain/repositories/tags_repository.dart';
import 'package:ondas_mobile/features/tags/domain/usecases/get_tags_usecase.dart';

class GetTagsUseCaseImpl implements GetTagsUseCase {
  final TagsRepository _repository;

  const GetTagsUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, List<Tag>>> call({String? type}) {
    return _repository.getTags(type: type);
  }
}
