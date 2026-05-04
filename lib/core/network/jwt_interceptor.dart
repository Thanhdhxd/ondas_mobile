import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

class JwtInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  // Separate Dio for token refresh to avoid interceptor loop
  late final Dio _refreshDio;

  JwtInterceptor(this._secureStorage) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Auth endpoints are public — never attach a token to avoid 401
    // when an old/expired token is still in storage.
    final isAuthEndpoint = options.path.startsWith('/api/auth/');
    if (!isAuthEndpoint) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = '${AppConstants.bearerPrefix}$token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        final response = await _refreshDio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await _secureStorage.saveAccessToken(newAccessToken);
        await _secureStorage.saveRefreshToken(newRefreshToken);

        // Retry the original request with new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] =
            '${AppConstants.bearerPrefix}$newAccessToken';

        final retryDio = Dio();
        final retryResponse = await retryDio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _secureStorage.clearTokens();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
