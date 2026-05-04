import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';
import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/get_favorites_usecase.dart';

class GetFavoritesUseCaseImpl implements GetFavoritesUseCase {
  final FavoritesRepository _repository;

  const GetFavoritesUseCaseImpl(this._repository);

  @override
  Future<PageResult<FavoriteItem>> call({int page = 0, int size = 20}) =>
      _repository.getFavorites(page: page, size: size);
}
