import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/add_favorite_usecase.dart';

class AddFavoriteUseCaseImpl implements AddFavoriteUseCase {
  final FavoritesRepository _repository;

  const AddFavoriteUseCaseImpl(this._repository);

  @override
  Future<void> call(String songId) => _repository.addFavorite(songId);
}
