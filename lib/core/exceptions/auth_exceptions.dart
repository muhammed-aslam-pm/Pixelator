class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class LoginException extends AuthException {
  const LoginException(String message, [int? statusCode])
      : super(message, statusCode);
}

class TokenRefreshException extends AuthException {
  const TokenRefreshException(String message, [int? statusCode])
      : super(message, statusCode);
}

class NetworkException extends AuthException {
  const NetworkException(String message) : super(message);
}

class ServerException extends AuthException {
  const ServerException(String message, [int? statusCode])
      : super(message, statusCode);
}

