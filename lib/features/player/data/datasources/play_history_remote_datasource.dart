abstract class PlayHistoryRemoteDatasource {
  Future<void> recordPlayHistory({required String songId, String? source});
}
