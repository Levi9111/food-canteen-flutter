class AppConstants {
  static const String appName = 'RTS Food Canteen';
  static const String appTagline = 'Fresh & Quick Meals at Your Fingertips';

  // API Config
  static const String defaultBaseUrl = 'http://localhost:5000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'auth_user';
  static const String themeModeKey = 'theme_mode';
}
