import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import '../exceptions/auth_exceptions.dart';
import '../utils/logger.dart';
import '../../data/models/auth_token_model.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;
  bool _isRefreshing = false;
  final _refreshQueue =
      <({Completer<void> completer, RequestOptions options})>[];

  AuthInterceptor(this.tokenStorage, this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for login and refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    final accessToken = await tokenStorage.getAccessToken();
    final tokenType = await tokenStorage.getTokenType();

    if (accessToken != null && tokenType != null) {
      options.headers['Authorization'] = '$tokenType $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      // Token expired, try to refresh
      try {
        final newRequest = await _refreshToken(err.requestOptions);
        handler.resolve(newRequest);
      } catch (e) {
        // Refresh failed, clear tokens and reject
        AppLogger.e('Token refresh failed in interceptor', e);
        await tokenStorage.clearTokens();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const TokenRefreshException(
              'Session expired. Please login again.',
            ),
          ),
        );
      }
    } else {
      handler.next(err);
    }
  }

  Future<Response> _refreshToken(RequestOptions options) async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      final completer = Completer<void>();
      _refreshQueue.add((completer: completer, options: options));
      await completer.future;
      return _retry(options);
    }

    _isRefreshing = true;

    try {
      AppLogger.i('Attempting to refresh token');
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.w('No refresh token available');
        throw const TokenRefreshException('No refresh token available');
      }

      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await refreshDio.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokenModel = AuthTokenModel.fromJson(response.data);
        await tokenStorage.saveTokens(
          accessToken: tokenModel.accessToken,
          refreshToken: tokenModel.refreshToken,
          tokenType: tokenModel.tokenType,
          expiresIn: tokenModel.expiresIn,
        );
        AppLogger.i('Token refreshed successfully');

        // Complete all pending requests
        for (final item in _refreshQueue) {
          item.completer.complete();
        }
        _refreshQueue.clear();
        _isRefreshing = false;

        return _retry(options);
      } else {
        AppLogger.e('Token refresh failed with status: ${response.statusCode}');
        throw TokenRefreshException(
          'Token refresh failed',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Token refresh error', e, stackTrace);
      _isRefreshing = false;
      for (final item in _refreshQueue) {
        item.completer.completeError(e);
      }
      _refreshQueue.clear();
      rethrow;
    }
  }

  Future<Response> _retry(RequestOptions options) async {
    final accessToken = await tokenStorage.getAccessToken();
    final tokenType = await tokenStorage.getTokenType();

    options.headers['Authorization'] = '$tokenType $accessToken';

    return dio.request(
      options.path,
      options: Options(method: options.method, headers: options.headers),
      data: options.data,
      queryParameters: options.queryParameters,
    );
  }
}
