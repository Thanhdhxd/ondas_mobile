import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

abstract class UploadAvatarUseCase {
  Future<Either<Failure, UserProfile>> call(UploadAvatarParams params);
}

class UploadAvatarParams {
  final String filePath;

  const UploadAvatarParams({required this.filePath});
}
