import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';

abstract class FavoritesRepository {
  Future<void> addFavorite(String songId);
  Future<void> removeFavorite(String songId);
  Future<bool> checkFavoriteStatus(String songId);
  Future<PageResult<FavoriteItem>> getFavorites({int page = 0, int size = 20});
}
