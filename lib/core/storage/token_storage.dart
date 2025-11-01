import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getTokenType();
  Future<DateTime?> getTokenExpiry();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class TokenStorageImpl implements TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorageImpl(this._storage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) async {
    final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
    
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      _storage.write(key: AppConstants.tokenTypeKey, value: tokenType),
      _storage.write(
        key: AppConstants.tokenExpiryKey,
        value: expiryDate.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<String?> getTokenType() {
    return _storage.read(key: AppConstants.tokenTypeKey);
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: AppConstants.tokenExpiryKey);
    if (expiryString == null) return null;
    return DateTime.parse(expiryString);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.tokenTypeKey),
      _storage.delete(key: AppConstants.tokenExpiryKey),
    ]);
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }
}

