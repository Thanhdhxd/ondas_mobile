import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ondas_mobile/features/auth/data/models/auth_response_model.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final DioClient _dioClient;

  const AuthRemoteDatasourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {'displayName': fullName, 'email': email, 'password': password},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _dioClient.delete<void>(
      ApiConstants.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dioClient.post<void>(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dioClient.post<void>(
      ApiConstants.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }
}
