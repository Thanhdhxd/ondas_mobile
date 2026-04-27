import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/data/models/play_history_item_model.dart';
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

  Future<PageResult<PlayHistoryItemModel>> getPlayHistory({
    required int page,
    required int size,
  });

  Future<void> deletePlayHistoryItem({required int id});

  Future<void> clearPlayHistory();
}
