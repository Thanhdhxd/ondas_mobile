import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'play_history_remote_datasource.dart';

class PlayHistoryRemoteDatasourceImpl implements PlayHistoryRemoteDatasource {
  final DioClient _dioClient;

  const PlayHistoryRemoteDatasourceImpl(this._dioClient);

  @override
  Future<void> recordPlayHistory({required String songId, String? source}) async {
    final body = <String, dynamic>{'songId': songId};
    if (source != null) body['source'] = source;
    await _dioClient.post<dynamic>(ApiConstants.playHistory, data: body);
  }
}
