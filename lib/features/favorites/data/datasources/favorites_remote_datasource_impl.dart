import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:ondas_mobile/features/favorites/data/models/favorite_song_model.dart';

class FavoritesRemoteDatasourceImpl implements FavoritesRemoteDatasource {
  final DioClient _dioClient;

  const FavoritesRemoteDatasourceImpl(this._dioClient);

  @override
  Future<void> addFavorite(String songId) async {
    await _dioClient.post<dynamic>(ApiConstants.favoriteSong(songId));
  }

  @override
  Future<void> removeFavorite(String songId) async {
    await _dioClient.delete<dynamic>(ApiConstants.favoriteSong(songId));
  }

  @override
  Future<bool> checkFavoriteStatus(String songId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.favoriteStatus(songId),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => json as bool,
    );
    return apiResponse.data ?? false;
  }

  @override
  Future<PageResult<FavoriteItemModel>> getFavorites({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.favorites,
      queryParameters: {'page': page, 'size': size},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        FavoriteItemModel.fromJson,
      ),
    );
    return apiResponse.data!;
  }
}
