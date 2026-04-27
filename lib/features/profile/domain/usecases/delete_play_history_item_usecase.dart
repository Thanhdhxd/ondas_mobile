import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class DeletePlayHistoryItemUseCase {
  Future<Either<Failure, void>> call(DeletePlayHistoryItemParams params);
}

class DeletePlayHistoryItemParams {
  final int id;

  const DeletePlayHistoryItemParams({required this.id});
}
