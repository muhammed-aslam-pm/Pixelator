import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';

    logger.e(
      '⛔ ERROR on ${options.method} request ==> $requestPath',
    ); // Error log
    logger.d('📤 REQUEST BODY: ${options.data.toString()}'); // Log request body
    logger.d(
      '📤 REQUEST QUERY PARAMS: ${options.queryParameters}',
    ); // Log request body

    if (err.response != null) {
      logger.e('📥 RESPONSE STATUS CODE: ${err.response?.statusCode}');
      logger.e('📝 RESPONSE MESSAGE: ${err.response?.statusMessage}');
      logger.e('📊 RESPONSE DATA: ${err.response?.data}');
    } else {
      logger.e('❌ No response received. Possible network issue.');
    }

    handler.next(err); // Continue with the error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('💡 ${options.method} request ==> $requestPath'); // Info log
    logger.d(
      '📨 Headers: ${options.headers} \n 🔍 Data: ${options.data}',
    ); // Debug log
    handler.next(options); // Continue with the request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestPath =
        '${response.requestOptions.baseUrl}${response.requestOptions.path}';
    logger.i('✅ Response from ==> $requestPath'); // Info log
    logger.d(
      '📜 STATUS CODE: ${response.statusCode} \n '
      '📝 STATUS MESSAGE: ${response.statusMessage} \n'
      '📩 HEADERS: ${response.headers} \n',
    ); // Debug log
    log('📊 RESPONSE DATA of $requestPath : ${response.data}');
    handler.next(response); // Continue with the response
  }
}
