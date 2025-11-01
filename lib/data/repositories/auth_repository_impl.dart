import '../../core/storage/token_storage.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  UserEntity? _cachedUser;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<UserEntity> login(String email, String password) async {
    // Login and get tokens
    final tokenModel = await remoteDataSource.login(email, password);
    
    // Store tokens
    await tokenStorage.saveTokens(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
      tokenType: tokenModel.tokenType,
      expiresIn: tokenModel.expiresIn,
    );

    // Get and return current user info
    final user = await getCurrentUser();
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      // Call logout API
      await remoteDataSource.logout();
      AppLogger.i('Logout API call successful');
    } catch (e) {
      AppLogger.e('Logout API call failed, clearing tokens anyway', e);
      // Clear tokens even if API call fails
    } finally {
      // Always clear tokens and cache
      await tokenStorage.clearTokens();
      _cachedUser = null;
      AppLogger.i('Tokens and user cache cleared');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    if (!(await tokenStorage.hasTokens())) {
      return false;
    }
    final expiry = await tokenStorage.getTokenExpiry();
    if (expiry == null) return false;
    // Consider token expired if it expires within 5 minutes
    return !DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    return _cachedUser;
  }
}
