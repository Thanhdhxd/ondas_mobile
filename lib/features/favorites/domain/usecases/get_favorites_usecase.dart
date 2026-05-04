import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';

abstract class GetFavoritesUseCase {
  Future<PageResult<FavoriteItem>> call({int page = 0, int size = 20});
}
