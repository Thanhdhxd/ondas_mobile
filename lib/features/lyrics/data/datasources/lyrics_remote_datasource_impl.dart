import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/lyrics/data/datasources/lyrics_remote_datasource.dart';
import 'package:ondas_mobile/features/lyrics/data/models/lyrics_model.dart';

class LyricsRemoteDatasourceImpl implements LyricsRemoteDatasource {
  final DioClient _dioClient;

  const LyricsRemoteDatasourceImpl(this._dioClient);

  @override
  Future<LyricsModel> getLyrics(String songId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.songLyrics(songId),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => LyricsModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }
}
