class AppConstants {
  static const String appName = 'Food Canteen RTS';
  static const String institutionName = 'Recruits Training School';
  static const String organizationName = 'Bangladesh Air Force';
  static const String appSubtitle = 'Mess & Canteen Accounts Management System';

  // Assets
  static const String bafEmblemPath = 'assets/images/Bangladesh Air Force Crest Emblem.png';
  static const String bafLogoPath = 'assets/images/baf_logo.png';
  static const String bafCrestPath = 'assets/images/baf_crest.png';

  // API Config
  static const String defaultBaseUrl =
      'https://food-canteen-server.onrender.com/api/v1';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'auth_user';
  static const String themeModeKey = 'theme_mode';
}
