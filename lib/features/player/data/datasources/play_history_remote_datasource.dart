abstract class PlayHistoryRemoteDatasource {
  Future<void> recordPlayHistory({
    required String songId,
    String? source,
    int? durationPlayedSeconds,
    bool? completed,
  });
}
