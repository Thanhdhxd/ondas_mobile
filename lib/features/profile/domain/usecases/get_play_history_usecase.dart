import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';

abstract class GetPlayHistoryUseCase {
  Future<Either<Failure, PageResult<PlayHistoryItem>>> call(
    GetPlayHistoryParams params,
  );
}

class GetPlayHistoryParams {
  final int page;
  final int size;

  const GetPlayHistoryParams({required this.page, required this.size});
}
