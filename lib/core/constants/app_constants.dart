class AppConstants {
  static const String baseUrl = 'https://pixelator-api.genesysailabs.com';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  static const String currentUserEndpoint = '/api/v1/auth/me';
  static const String logoutEndpoint = '/api/v1/auth/logout';

  static const String casesEndpoint = '/api/v1/cases/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenTypeKey = 'token_type';
  static const String expiresInKey = 'expires_in';
  static const String tokenExpiryKey = 'token_expiry';

  static const String appLogo = 'assets/images/pixelator.png';
}
