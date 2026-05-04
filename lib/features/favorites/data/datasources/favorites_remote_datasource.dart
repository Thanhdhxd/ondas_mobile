import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/favorites/data/models/favorite_song_model.dart';

abstract class FavoritesRemoteDatasource {
  Future<void> addFavorite(String songId);
  Future<void> removeFavorite(String songId);
  Future<bool> checkFavoriteStatus(String songId);
  Future<PageResult<FavoriteItemModel>> getFavorites({int page = 0, int size = 20});
}
