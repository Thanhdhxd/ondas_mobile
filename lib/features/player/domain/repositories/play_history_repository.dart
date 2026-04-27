abstract class PlayHistoryRepository {
  Future<void> recordPlayHistory({required String songId, String? source});
}
