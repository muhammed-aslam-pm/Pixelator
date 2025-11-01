import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void apiCall(String method, String url, {Map<String, dynamic>? data}) {
    _logger.i('API CALL: $method $url', error: data);
  }

  static void apiResponse(String method, String url, int? statusCode, dynamic response) {
    _logger.i('API RESPONSE: $method $url [${statusCode ?? 'N/A'}]', error: response);
  }

  static void apiError(String method, String url, dynamic error) {
    _logger.e('API ERROR: $method $url', error: error);
  }
}
