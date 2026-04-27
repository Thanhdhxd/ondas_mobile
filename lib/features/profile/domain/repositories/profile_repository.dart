import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';
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

  Future<Either<Failure, PageResult<PlayHistoryItem>>> getPlayHistory({
    required int page,
    required int size,
  });

  Future<Either<Failure, void>> deletePlayHistoryItem({required int id});

  Future<Either<Failure, void>> clearPlayHistory();
}
