import 'package:ondas_mobile/features/player/domain/repositories/play_history_repository.dart';
import 'package:ondas_mobile/features/player/domain/usecases/record_play_history_usecase.dart';

class RecordPlayHistoryUseCaseImpl implements RecordPlayHistoryUseCase {
  final PlayHistoryRepository _repository;

  const RecordPlayHistoryUseCaseImpl(this._repository);

  @override
  Future<void> call({required String songId, String? source}) {
    return _repository.recordPlayHistory(songId: songId, source: source);
  }
}
