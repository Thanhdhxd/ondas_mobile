import 'package:ondas_mobile/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/check_favorite_status_usecase.dart';

class CheckFavoriteStatusUseCaseImpl implements CheckFavoriteStatusUseCase {
  final FavoritesRepository _repository;

  const CheckFavoriteStatusUseCaseImpl(this._repository);

  @override
  Future<bool> call(String songId) => _repository.checkFavoriteStatus(songId);
}
