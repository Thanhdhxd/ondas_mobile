import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/remove_favorite_usecase.dart';

class RemoveFavoriteUseCaseImpl implements RemoveFavoriteUseCase {
  final FavoritesRepository _repository;

  const RemoveFavoriteUseCaseImpl(this._repository);

  @override
  Future<void> call(String songId) => _repository.removeFavorite(songId);
}
