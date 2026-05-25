import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/app_constants.dart';
import 'package:ondas_mobile/core/error/failures.dart';

class DioFailureMapper {
  const DioFailureMapper._();

  static Failure map(
    DioException exception, {
    String? notFoundMessage,
  }) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedFailure();
    if (statusCode == 404 && notFoundMessage != null) {
      return NotFoundFailure(message: notFoundMessage);
    }
    if (_isConnectionError(exception)) {
      return const NetworkFailure(message: AppConstants.offlineErrorMessage);
    }
    final message = _extractMessage(exception);
    return ServerFailure(message: message, statusCode: statusCode);
  }

  static bool _isConnectionError(DioException exception) {
    return exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        (exception.type == DioExceptionType.unknown &&
            exception.error is SocketException);
  }

  static String _extractMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    if (exception.message != null && exception.message!.isNotEmpty) {
      return exception.message!;
    }
    return AppConstants.genericErrorMessage;
  }
}
