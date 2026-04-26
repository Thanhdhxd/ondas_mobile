import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  Future<Either<Failure, UserProfile>> updateProfile({
    required String displayName,
  });

  Future<Either<Failure, UserProfile>> uploadAvatar({
    required String filePath,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
