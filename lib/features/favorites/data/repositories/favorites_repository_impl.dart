import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';
import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDatasource _datasource;

  const FavoritesRepositoryImpl(this._datasource);

  @override
  Future<void> addFavorite(String songId) => _datasource.addFavorite(songId);

  @override
  Future<void> removeFavorite(String songId) => _datasource.removeFavorite(songId);

  @override
  Future<bool> checkFavoriteStatus(String songId) =>
      _datasource.checkFavoriteStatus(songId);

  @override
  Future<PageResult<FavoriteItem>> getFavorites({int page = 0, int size = 20}) =>
      _datasource.getFavorites(page: page, size: size);
}
