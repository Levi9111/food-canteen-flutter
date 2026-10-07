import '../constants/app_constants.dart';

class ApiEndpoints {
  static const String baseUrl = AppConstants.defaultBaseUrl;

  // Auth & User Management
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String users = '/auth/users';
  static const String changePassword = '/auth/change-password';

  static String deleteUser(String id) => '/auth/users/$id';

  // Squadrons & Rooms
  static const String squadrons = '/squadrons';
  static String squadronRooms(String name) => '/squadrons/$name/rooms';

  // Entry Batches
  static const String entries = '/entries';
  static const String activeEntry = '/entries/active';
  static String activateEntry(String id) => '/entries/$id/activate';

  // Canteen Modules
  static const String pstaffs = '/pstaffs';
  static const String staffExpenses = '/staff-expenses';
  static const String roomExpenses = '/room-expenses';
  static const String payments = '/payments';
  static const String offices = '/offices';
}
