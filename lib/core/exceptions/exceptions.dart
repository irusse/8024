class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, [this.statusCode]);
}

class BadRequestException implements Exception {
  final String message;

  const BadRequestException(this.message);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}
