import 'package:ondas_mobile/features/player/data/datasources/play_history_remote_datasource.dart';
import 'package:ondas_mobile/features/player/domain/repositories/play_history_repository.dart';

class PlayHistoryRepositoryImpl implements PlayHistoryRepository {
  final PlayHistoryRemoteDatasource _datasource;

  const PlayHistoryRepositoryImpl(this._datasource);

  @override
  Future<void> recordPlayHistory({required String songId, String? source}) {
    return _datasource.recordPlayHistory(songId: songId, source: source);
  }
}
