import '../constants/app_constants.dart';

class ApiEndpoints {
  static const String baseUrl = AppConstants.defaultBaseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Food / Menu endpoints (future-ready)
  static const String menuItems = '/menu';
  static const String categories = '/categories';

  // Orders endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
}
