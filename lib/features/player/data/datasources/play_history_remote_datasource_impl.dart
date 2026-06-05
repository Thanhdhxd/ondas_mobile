import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'play_history_remote_datasource.dart';

class PlayHistoryRemoteDatasourceImpl implements PlayHistoryRemoteDatasource {
  final DioClient _dioClient;

  const PlayHistoryRemoteDatasourceImpl(this._dioClient);

  @override
  Future<void> recordPlayHistory({
    required String songId,
    String? source,
    int? durationPlayedSeconds,
    bool? completed,
  }) async {
    final body = <String, dynamic>{'songId': songId};
    if (source != null) body['source'] = source;
    if (durationPlayedSeconds != null) {
      body['durationPlayedSeconds'] = durationPlayedSeconds;
    }
    if (completed != null) body['completed'] = completed;
    await _dioClient.post<dynamic>(ApiConstants.playHistory, data: body);
  }
}
