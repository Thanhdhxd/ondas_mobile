import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';

const _adminEmail = 'admin@e2e.local';
const _adminPassword = 'E2ePass123!';
const _e2eResetPath = '/api/admin/e2e/reset';

Future<void> resetE2EData() async {
  final token = await _fetchAdminAccessToken();
  final dio = sl<DioClient>();
  await dio.post<void>(
    _e2eResetPath,
    options: Options(
      headers: {
        'Authorization': '${AppConstants.bearerPrefix}$token',
      },
    ),
  );
}

Future<void> registerUser({
  required String fullName,
  required String email,
  required String password,
}) async {
  final dio = sl<DioClient>();
  await dio.post<void>(
    ApiConstants.register,
    data: {
      'displayName': fullName,
      'email': email,
      'password': password,
    },
  );
}

Future<Map<String, dynamic>> fetchProfile({required String accessToken}) async {
  final dio = sl<DioClient>();
  final response = await dio.get<Map<String, dynamic>>(
    ApiConstants.profile,
    options: Options(
      headers: {
        'Authorization': '${AppConstants.bearerPrefix}$accessToken',
      },
    ),
  );
  final data = response.data?['data'] as Map<String, dynamic>?;
  if (data == null) {
    throw StateError('Missing profile data');
  }
  return data;
}

Future<String> _fetchAdminAccessToken() async {
  final dio = sl<DioClient>();
  final response = await dio.post<Map<String, dynamic>>(
    ApiConstants.login,
    data: {
      'email': _adminEmail,
      'password': _adminPassword,
    },
  );
  final data = response.data?['data'] as Map<String, dynamic>?;
  final token = data?['accessToken'] as String?;
  if (token == null || token.isEmpty) {
    throw StateError('Missing admin access token');
  }
  return token;
}
