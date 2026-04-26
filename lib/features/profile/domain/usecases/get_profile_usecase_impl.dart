import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase.dart';

class GetProfileUseCaseImpl implements GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call() {
    return _repository.getProfile();
  }
}
