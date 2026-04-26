import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:ondas_mobile/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioClient _dioClient;

  const ProfileRemoteDatasourceImpl(this._dioClient);

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _dioClient.get<Map<String, dynamic>>(ApiConstants.profile);
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String displayName,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.profile,
      data: {'displayName': displayName},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<UserProfileModel> uploadAvatar({required String filePath}) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });
    final response = await _dioClient.patch<Map<String, dynamic>>(
      ApiConstants.avatarUpload,
      data: formData,
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.put<void>(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
