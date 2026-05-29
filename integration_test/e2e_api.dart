import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

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

/// Ensures [songId] appears as the most recent favorite for the logged-in user.
///
/// If the song is already a favorite, it is removed first then re-added so that
/// its `createdAt` timestamp becomes `NOW()`, placing it on the first page of
/// the paginated favorites list (sorted DESC by created_at).
Future<void> likeSong(String songId) async {
  final token = await sl<SecureStorage>().getAccessToken();
  if (token == null || token.isEmpty) return; // not logged in, skip silently
  final dio = sl<DioClient>();

  // Remove first (409 if not a favorite is fine)
  try {
    await dio.delete<void>(
      ApiConstants.favoriteSong(songId),
      options: Options(
        headers: {'Authorization': '${AppConstants.bearerPrefix}$token'},
      ),
    );
  } on DioException catch (_) {
    // ignore — song might not be in favorites yet
  }

  // Re-add so it gets a fresh createdAt = NOW()
  await dio.post<void>(
    ApiConstants.favoriteSong(songId),
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
