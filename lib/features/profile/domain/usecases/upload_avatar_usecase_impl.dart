import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase.dart';

class UploadAvatarUseCaseImpl implements UploadAvatarUseCase {
  final ProfileRepository _repository;

  const UploadAvatarUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(UploadAvatarParams params) {
    return _repository.uploadAvatar(filePath: params.filePath);
  }
}
