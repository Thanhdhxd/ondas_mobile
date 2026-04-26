import 'package:ondas_mobile/features/profile/data/models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel> getProfile();

  Future<UserProfileModel> updateProfile({
    required String displayName,
  });

  Future<UserProfileModel> uploadAvatar({
    required String filePath,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
