class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException($message)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException($message)';
}
