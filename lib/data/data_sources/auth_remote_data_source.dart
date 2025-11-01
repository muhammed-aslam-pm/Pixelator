import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/auth_token_model.dart';
import '../models/error_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String email, String password);
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    AppLogger.apiCall('POST', AppConstants.loginEndpoint, data: {'email': email});
    
    try {
      final response = await dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      AppLogger.apiResponse('POST', AppConstants.loginEndpoint, response.statusCode, response.data);

      if (response.statusCode == 200) {
        final tokenModel = AuthTokenModel.fromJson(response.data);
        AppLogger.i('Login successful for: $email');
        return tokenModel;
      } else {
        AppLogger.e('Login failed with status: ${response.statusCode}', response.data);
        throw ServerException(
          'Login failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError('POST', AppConstants.loginEndpoint, e);
      AppLogger.e('Login DioException: ${e.type}', e.response?.data, e.stackTrace);
      
      if (e.response?.statusCode == 401) {
        final errorResponse = ErrorResponseModel.fromJson(
          e.response?.data ?? {'detail': 'Incorrect email or password'},
        );
        AppLogger.w('Login failed: ${errorResponse.detail}');
        throw LoginException(errorResponse.detail, 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('Login timeout');
        throw const NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.e('Login connection error');
        throw const NetworkException('No internet connection. Please check your network settings.');
      } else if (e.response != null) {
        // Server error with response
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          AppLogger.e('Login server error: $statusCode');
          throw ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        AppLogger.e('Login error: ${e.response?.data}');
        throw ServerException(
          e.response?.data?['detail'] ?? 'An error occurred',
          statusCode,
        );
      } else {
        AppLogger.e('Login network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.e('Login AuthException: ${e.message}', stackTrace);
        rethrow;
      }
      AppLogger.e('Login unexpected error: ${e.toString()}', e, stackTrace);
      throw LoginException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    AppLogger.apiCall('POST', AppConstants.refreshTokenEndpoint);
    
    try {
      final response = await dio.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      AppLogger.apiResponse('POST', AppConstants.refreshTokenEndpoint, response.statusCode, response.data);

      if (response.statusCode == 200) {
        final tokenModel = AuthTokenModel.fromJson(response.data);
        AppLogger.i('Token refresh successful');
        return tokenModel;
      } else {
        AppLogger.e('Token refresh failed with status: ${response.statusCode}', response.data);
        throw TokenRefreshException(
          'Token refresh failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError('POST', AppConstants.refreshTokenEndpoint, e);
      AppLogger.e('Refresh token DioException: ${e.type}', e.response?.data, e.stackTrace);
      
      if (e.response?.statusCode == 401) {
        AppLogger.w('Refresh token expired');
        throw const TokenRefreshException('Refresh token expired. Please login again.', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('Refresh token timeout');
        throw const NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.e('Refresh token connection error');
        throw const NetworkException('No internet connection. Please check your network settings.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          AppLogger.e('Refresh token server error: $statusCode');
          throw ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        AppLogger.e('Refresh token error: ${e.response?.data}');
        throw TokenRefreshException(
          e.response?.data?['detail'] ?? 'Token refresh failed',
          statusCode,
        );
      } else {
        AppLogger.e('Refresh token network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.e('Refresh token AuthException: ${e.message}', stackTrace);
        rethrow;
      }
      AppLogger.e('Refresh token unexpected error: ${e.toString()}', e, stackTrace);
      throw TokenRefreshException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    AppLogger.apiCall('GET', AppConstants.currentUserEndpoint);
    
    try {
      final response = await dio.get(AppConstants.currentUserEndpoint);

      AppLogger.apiResponse('GET', AppConstants.currentUserEndpoint, response.statusCode, response.data);

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(response.data);
        AppLogger.i('Current user fetched: ${userModel.email}');
        return userModel;
      } else {
        AppLogger.e('Get current user failed with status: ${response.statusCode}', response.data);
        throw ServerException(
          'Failed to get user information',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError('GET', AppConstants.currentUserEndpoint, e);
      AppLogger.e('Get current user DioException: ${e.type}', e.response?.data, e.stackTrace);
      
      if (e.response?.statusCode == 401) {
        AppLogger.w('Get current user unauthorized');
        throw const AuthException('Unauthorized. Please login again.', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('Get current user timeout');
        throw const NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.e('Get current user connection error');
        throw const NetworkException('No internet connection. Please check your network settings.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          AppLogger.e('Get current user server error: $statusCode');
          throw ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        AppLogger.e('Get current user error: ${e.response?.data}');
        throw ServerException(
          e.response?.data?['detail'] ?? 'Failed to get user information',
          statusCode,
        );
      } else {
        AppLogger.e('Get current user network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.e('Get current user AuthException: ${e.message}', stackTrace);
        rethrow;
      }
      AppLogger.e('Get current user unexpected error: ${e.toString()}', e, stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    AppLogger.apiCall('POST', AppConstants.logoutEndpoint);
    
    try {
      final response = await dio.post(AppConstants.logoutEndpoint);

      AppLogger.apiResponse('POST', AppConstants.logoutEndpoint, response.statusCode, response.data);

      if (response.statusCode == 200) {
        AppLogger.i('Logout successful');
        return;
      } else {
        AppLogger.e('Logout failed with status: ${response.statusCode}', response.data);
        throw ServerException(
          'Logout failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError('POST', AppConstants.logoutEndpoint, e);
      AppLogger.e('Logout DioException: ${e.type}', e.response?.data, e.stackTrace);
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('Logout timeout');
        throw const NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.e('Logout connection error');
        throw const NetworkException('No internet connection. Please check your network settings.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          AppLogger.e('Logout server error: $statusCode');
          throw ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        AppLogger.e('Logout error: ${e.response?.data}');
        throw ServerException(
          e.response?.data?['detail'] ?? 'Logout failed',
          statusCode,
        );
      } else {
        AppLogger.e('Logout network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.e('Logout AuthException: ${e.message}', stackTrace);
        rethrow;
      }
      AppLogger.e('Logout unexpected error: ${e.toString()}', e, stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
