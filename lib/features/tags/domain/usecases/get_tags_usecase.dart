import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';

abstract class GetTagsUseCase {
  Future<Either<Failure, List<Tag>>> call({String? type});
}
