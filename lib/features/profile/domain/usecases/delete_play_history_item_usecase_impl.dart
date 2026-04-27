import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase.dart';

class DeletePlayHistoryItemUseCaseImpl implements DeletePlayHistoryItemUseCase {
  final ProfileRepository _repository;

  const DeletePlayHistoryItemUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call(DeletePlayHistoryItemParams params) {
    return _repository.deletePlayHistoryItem(id: params.id);
  }
}
