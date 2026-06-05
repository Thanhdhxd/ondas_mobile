abstract class RecordPlayHistoryUseCase {
  Future<void> call({
    required String songId,
    String? source,
    int? durationPlayedSeconds,
    bool? completed,
  });
}

class RecordPlayHistoryParams {
  final String songId;
  final String? source;

  const RecordPlayHistoryParams({required this.songId, this.source});
}
