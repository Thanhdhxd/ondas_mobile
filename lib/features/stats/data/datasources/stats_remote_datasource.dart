import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/stats/data/models/listening_time_stats_model.dart';
import 'package:ondas_mobile/features/stats/data/models/top_artist_stats_model.dart';
import 'package:ondas_mobile/features/stats/data/models/top_song_stats_model.dart';

abstract class StatsRemoteDatasource {
  Future<ListeningTimeStatsModel> getListeningTime();
  Future<List<TopSongStatsModel>> getTopSongs({int limit = 10});
  Future<List<TopArtistStatsModel>> getTopArtists({int limit = 10});
}

class StatsRemoteDatasourceImpl implements StatsRemoteDatasource {
  final DioClient _dioClient;

  const StatsRemoteDatasourceImpl(this._dioClient);

  @override
  Future<ListeningTimeStatsModel> getListeningTime() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.statsListeningTime,
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => ListeningTimeStatsModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<List<TopSongStatsModel>> getTopSongs({int limit = 10}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.statsTopSongs,
      queryParameters: {'limit': limit},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>).map((e) => TopSongStatsModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data!;
  }

  @override
  Future<List<TopArtistStatsModel>> getTopArtists({int limit = 10}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.statsTopArtists,
      queryParameters: {'limit': limit},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>).map((e) => TopArtistStatsModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data!;
  }
}
