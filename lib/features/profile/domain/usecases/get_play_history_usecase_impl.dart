import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase.dart';

class GetPlayHistoryUseCaseImpl implements GetPlayHistoryUseCase {
  final ProfileRepository _repository;

  const GetPlayHistoryUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, PageResult<PlayHistoryItem>>> call(
    GetPlayHistoryParams params,
  ) {
    return _repository.getPlayHistory(page: params.page, size: params.size);
  }
}
