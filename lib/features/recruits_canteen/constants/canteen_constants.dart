class CanteenConstants {
  // Hardcoded 4 Squadrons of RTS BAF
  static const List<String> squadrons = [
    'Sadruddin',
    'Liakot Ali',
    'Nurul Haque',
    'Mansur Ali',
  ];

  // Hardcoded Room Numbers
  static const List<String> rooms = [
    'Room 1',
    'Room 2',
    'Room 3',
    'Room 4',
    'Room 5',
    'Room 6',
    'Room 7',
    'Room 8',
    'Room 9',
    'Room 10',
    'Room 11',
    'Room 12',
    'Room 13',
    'Room 14',
    'Room 15',
    'Room 16',
  ];

  // User / Manager Roles
  static const String roleNcoic = 'NCOIC';
  static const String roleJcoic = 'JCOIC';
  static const List<String> managerRoles = [roleNcoic, roleJcoic];

  // Default Active Entry
  static const String defaultEntry = '54';

  // Persistence Keys
  static const String prefsKeyExpenses = 'rts_canteen_daily_expenses';
  static const String prefsKeyEntries = 'rts_canteen_entries_list';
  static const String prefsKeyActiveEntry = 'rts_canteen_active_entry';
  static const String prefsKeyActiveManager = 'rts_canteen_active_manager';
  static const String prefsKeyRoomDues = 'rts_canteen_room_dues';
  static const String prefsKeyRoomPaid = 'rts_canteen_room_paid';
  static const String prefsKeyRoomRanks = 'rts_canteen_room_ranks';
}
