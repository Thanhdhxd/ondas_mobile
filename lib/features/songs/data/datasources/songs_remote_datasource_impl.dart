import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/home/data/models/song_summary_model.dart';
import 'package:ondas_mobile/features/songs/data/datasources/songs_remote_datasource.dart';

class SongsRemoteDatasourceImpl implements SongsRemoteDatasource {
  final DioClient _dioClient;

  const SongsRemoteDatasourceImpl(this._dioClient);

  @override
  Future<PageResult<SongSummaryModel>> getSongs({
    String? artistId,
    String? albumId,
    int page = 0,
    int size = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
      'artistId': ?artistId,
      'albumId': ?albumId,
    };

    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.songs,
      queryParameters: queryParameters,
    );

    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        SongSummaryModel.fromJson,
      ),
    );

    return apiResponse.data!;
  }
}
