import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/canteen_constants.dart';
import '../models/daily_room_expense.dart';
import '../models/room_monthly_summary.dart';

class CanteenRegisterState {
  final String activeEntry;
  final List<String> allEntries;
  final String activeManager; // 'NCOIC' or 'JCOIC'
  final String selectedSquadron;
  final String selectedRoom;
  final DateTime selectedDate;
  final int selectedYear;
  final int selectedMonth;
  final Map<String, DailyRoomExpense> expenses; // Key: entry|squadron|room|yyyy-MM-dd
  final Map<String, double> roomPreDues;        // Key: entry|squadron|room
  final Map<String, double> roomPaid;           // Key: entry|squadron|room
  final Map<String, String> roomRanks;          // Key: entry|squadron|room
  final bool isLoading;

  const CanteenRegisterState({
    this.activeEntry = CanteenConstants.defaultEntry,
    this.allEntries = const ['54', '53', '52'],
    this.activeManager = CanteenConstants.roleNcoic,
    this.selectedSquadron = 'Sadruddin',
    this.selectedRoom = 'Room 1',
    required this.selectedDate,
    required this.selectedYear,
    required this.selectedMonth,
    this.expenses = const {},
    this.roomPreDues = const {},
    this.roomPaid = const {},
    this.roomRanks = const {},
    this.isLoading = false,
  });

  String makeKey(String entry, String squadron, String room, DateTime date) {
    final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$entry|$squadron|$room|$dStr';
  }

  String makeRoomKey(String entry, String squadron, String room) {
    return '$entry|$squadron|$room';
  }

  DailyRoomExpense? getExpense(String entry, String squadron, String room, DateTime date) {
    return expenses[makeKey(entry, squadron, room, date)];
  }

  double getRoomPreDue(String entry, String squadron, String room) {
    return roomPreDues[makeRoomKey(entry, squadron, room)] ?? 0.0;
  }

  double getRoomPaid(String entry, String squadron, String room) {
    return roomPaid[makeRoomKey(entry, squadron, room)] ?? 0.0;
  }

  String getRoomRank(String entry, String squadron, String room) {
    return roomRanks[makeRoomKey(entry, squadron, room)] ?? 'Rect Rep';
  }

  /// Calculates total price for a squadron on a single day
  double getSquadronDayTotal(String entry, String squadron, DateTime date) {
    double total = 0.0;
    for (final room in CanteenConstants.rooms) {
      final exp = getExpense(entry, squadron, room, date);
      if (exp != null) total += exp.amount;
    }
    return total;
  }

  /// Calculates total price for a room across a whole month
  double getRoomMonthTotal(String entry, String squadron, String room, int year, int month) {
    double total = 0.0;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final exp = getExpense(entry, squadron, room, date);
      if (exp != null) total += exp.amount;
    }
    return total;
  }

  /// Calculates grand total for a whole squadron in a month
  double getSquadronMonthTotal(String entry, String squadron, int year, int month) {
    double total = 0.0;
    for (final room in CanteenConstants.rooms) {
      total += getRoomMonthTotal(entry, squadron, room, year, month);
    }
    return total;
  }

  /// Sum of all Previous Dues in a Squadron
  double getSquadronPreDueTotal(String entry, String squadron) {
    double total = 0.0;
    for (final room in CanteenConstants.rooms) {
      total += getRoomPreDue(entry, squadron, room);
    }
    return total;
  }

  /// Sum of all Payments in a Squadron
  double getSquadronPaidTotal(String entry, String squadron) {
    double total = 0.0;
    for (final room in CanteenConstants.rooms) {
      total += getRoomPaid(entry, squadron, room);
    }
    return total;
  }

  /// Grand Total = Sum of PreDue + Month Spending
  double getSquadronGrandTotal(String entry, String squadron, int year, int month) {
    return getSquadronPreDueTotal(entry, squadron) + getSquadronMonthTotal(entry, squadron, year, month);
  }

  /// Net Closing Due = Grand Total - Paid
  double getSquadronNetDueTotal(String entry, String squadron, int year, int month) {
    return getSquadronGrandTotal(entry, squadron, year, month) - getSquadronPaidTotal(entry, squadron);
  }

  /// Generates the complete soft spreadsheet data structure for a room
  RoomMonthlySummary getRoomMonthlySummary(
    String entry,
    String squadron,
    String room,
    int year,
    int month,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<RoomDayRecord> days = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final exp = getExpense(entry, squadron, room, date);

      days.add(
        RoomDayRecord(
          dayNumber: day,
          date: date,
          amount: exp?.amount ?? 0.0,
          itemsDescription: exp?.itemsDescription,
          recordedBy: exp?.recordedBy ?? activeManager,
          representativeName: exp?.representativeName,
        ),
      );
    }

    return RoomMonthlySummary(
      entry: entry,
      squadron: squadron,
      room: room,
      year: year,
      month: month,
      rank: getRoomRank(entry, squadron, room),
      preDue: getRoomPreDue(entry, squadron, room),
      paid: getRoomPaid(entry, squadron, room),
      days: days,
    );
  }

  CanteenRegisterState copyWith({
    String? activeEntry,
    List<String>? allEntries,
    String? activeManager,
    String? selectedSquadron,
    String? selectedRoom,
    DateTime? selectedDate,
    int? selectedYear,
    int? selectedMonth,
    Map<String, DailyRoomExpense>? expenses,
    Map<String, double>? roomPreDues,
    Map<String, double>? roomPaid,
    Map<String, String>? roomRanks,
    bool? isLoading,
  }) {
    return CanteenRegisterState(
      activeEntry: activeEntry ?? this.activeEntry,
      allEntries: allEntries ?? this.allEntries,
      activeManager: activeManager ?? this.activeManager,
      selectedSquadron: selectedSquadron ?? this.selectedSquadron,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      expenses: expenses ?? this.expenses,
      roomPreDues: roomPreDues ?? this.roomPreDues,
      roomPaid: roomPaid ?? this.roomPaid,
      roomRanks: roomRanks ?? this.roomRanks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final canteenRegisterProvider =
    NotifierProvider<CanteenRegisterNotifier, CanteenRegisterState>(
  CanteenRegisterNotifier.new,
);

class CanteenRegisterNotifier extends Notifier<CanteenRegisterState> {
  bool _disposed = false;

  @override
  CanteenRegisterState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final now = DateTime.now();
    final initialState = CanteenRegisterState(
      selectedDate: now,
      selectedYear: now.year,
      selectedMonth: now.month,
      roomPreDues: _generateInitialPreDues(),
      roomPaid: _generateInitialPaid(),
      roomRanks: _generateInitialRanks(),
    );
    Future.microtask(() => _loadFromPrefs());
    return initialState;
  }

  Future<void> _loadFromPrefs() async {
    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final entriesJson = prefs.getStringList(CanteenConstants.prefsKeyEntries);
      final activeEntry = prefs.getString(CanteenConstants.prefsKeyActiveEntry) ?? CanteenConstants.defaultEntry;
      final activeManager = prefs.getString(CanteenConstants.prefsKeyActiveManager) ?? CanteenConstants.roleNcoic;
      final rawExpenses = prefs.getString(CanteenConstants.prefsKeyExpenses);
      final rawDues = prefs.getString(CanteenConstants.prefsKeyRoomDues);
      final rawPaid = prefs.getString(CanteenConstants.prefsKeyRoomPaid);
      final rawRanks = prefs.getString(CanteenConstants.prefsKeyRoomRanks);

      Map<String, DailyRoomExpense> loadedExpenses = {};
      if (rawExpenses != null && rawExpenses.isNotEmpty) {
        final decoded = jsonDecode(rawExpenses) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          loadedExpenses[key] = DailyRoomExpense.fromJson(val as Map<String, dynamic>);
        });
      } else {
        loadedExpenses = _generateDemoRecords();
      }

      Map<String, double> loadedDues = Map.from(state.roomPreDues);
      if (rawDues != null && rawDues.isNotEmpty) {
        final decoded = jsonDecode(rawDues) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          loadedDues[key] = (val as num).toDouble();
        });
      }

      Map<String, double> loadedPaid = Map.from(state.roomPaid);
      if (rawPaid != null && rawPaid.isNotEmpty) {
        final decoded = jsonDecode(rawPaid) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          loadedPaid[key] = (val as num).toDouble();
        });
      }

      Map<String, String> loadedRanks = Map.from(state.roomRanks);
      if (rawRanks != null && rawRanks.isNotEmpty) {
        final decoded = jsonDecode(rawRanks) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          loadedRanks[key] = val.toString();
        });
      }

      if (_disposed) return;
      state = state.copyWith(
        activeEntry: activeEntry,
        allEntries: entriesJson ?? state.allEntries,
        activeManager: activeManager,
        expenses: loadedExpenses,
        roomPreDues: loadedDues,
        roomPaid: loadedPaid,
        roomRanks: loadedRanks,
      );
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(expenses: _generateDemoRecords());
      }
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(CanteenConstants.prefsKeyEntries, state.allEntries);
      await prefs.setString(CanteenConstants.prefsKeyActiveEntry, state.activeEntry);
      await prefs.setString(CanteenConstants.prefsKeyActiveManager, state.activeManager);

      final Map<String, dynamic> serializableExp = {};
      state.expenses.forEach((k, v) => serializableExp[k] = v.toJson());
      await prefs.setString(CanteenConstants.prefsKeyExpenses, jsonEncode(serializableExp));

      await prefs.setString(CanteenConstants.prefsKeyRoomDues, jsonEncode(state.roomPreDues));
      await prefs.setString(CanteenConstants.prefsKeyRoomPaid, jsonEncode(state.roomPaid));
      await prefs.setString(CanteenConstants.prefsKeyRoomRanks, jsonEncode(state.roomRanks));
    } catch (_) {}
  }

  void setActiveEntry(String entry) {
    state = state.copyWith(activeEntry: entry);
    _saveToPrefs();
  }

  void addNewEntry(String newEntry) {
    final trimmed = newEntry.trim();
    if (trimmed.isEmpty || state.allEntries.contains(trimmed)) return;
    final updated = [trimmed, ...state.allEntries];
    state = state.copyWith(allEntries: updated, activeEntry: trimmed);
    _saveToPrefs();
  }

  void setActiveManager(String manager) {
    if (CanteenConstants.managerRoles.contains(manager)) {
      state = state.copyWith(activeManager: manager);
      _saveToPrefs();
    }
  }

  void setSelectedSquadron(String sqn) {
    state = state.copyWith(selectedSquadron: sqn);
  }

  void setSelectedRoom(String room) {
    state = state.copyWith(selectedRoom: room);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedYear: date.year,
      selectedMonth: date.month,
    );
  }

  void setSelectedMonth(int year, int month) {
    state = state.copyWith(selectedYear: year, selectedMonth: month);
  }

  Future<void> recordRoomExpense({
    required String room,
    required double amount,
    DateTime? date,
    String? representativeName,
    String? itemsDescription,
  }) async {
    final targetDate = date ?? state.selectedDate;
    final key = state.makeKey(state.activeEntry, state.selectedSquadron, room, targetDate);

    final expense = DailyRoomExpense(
      id: key,
      entry: state.activeEntry,
      squadron: state.selectedSquadron,
      room: room,
      date: targetDate,
      amount: amount,
      recordedBy: state.activeManager,
      representativeName: representativeName,
      itemsDescription: itemsDescription,
      updatedAt: DateTime.now(),
    );

    final updated = Map<String, DailyRoomExpense>.from(state.expenses);
    updated[key] = expense;
    state = state.copyWith(expenses: updated);
    await _saveToPrefs();
  }

  Future<void> updateRoomPreDue(String room, double preDue) async {
    final key = state.makeRoomKey(state.activeEntry, state.selectedSquadron, room);
    final updated = Map<String, double>.from(state.roomPreDues);
    updated[key] = preDue;
    state = state.copyWith(roomPreDues: updated);
    await _saveToPrefs();
  }

  Future<void> updateRoomPaid(String room, double paid) async {
    final key = state.makeRoomKey(state.activeEntry, state.selectedSquadron, room);
    final updated = Map<String, double>.from(state.roomPaid);
    updated[key] = paid;
    state = state.copyWith(roomPaid: updated);
    await _saveToPrefs();
  }

  Future<void> updateRoomRank(String room, String rank) async {
    final key = state.makeRoomKey(state.activeEntry, state.selectedSquadron, room);
    final updated = Map<String, String>.from(state.roomRanks);
    updated[key] = rank;
    state = state.copyWith(roomRanks: updated);
    await _saveToPrefs();
  }

  /// Initial Pre Due amounts based on the user's scanned register PDF
  static Map<String, double> _generateInitialPreDues() {
    final Map<String, double> map = {};
    const entry = '54';
    final sampleDues = [
      420.0, 302.0, 877.0, 1518.0, 430.0, 296.0, 360.0, 234.0,
      130.0, 405.0, 65.0, 641.0, 699.0, 545.0, 180.0, 240.0,
    ];

    for (final sqn in CanteenConstants.squadrons) {
      for (int i = 0; i < CanteenConstants.rooms.length; i++) {
        final room = CanteenConstants.rooms[i];
        final key = '$entry|$sqn|$room';
        map[key] = sampleDues[i % sampleDues.length];
      }
    }
    return map;
  }

  /// Initial Paid amounts
  static Map<String, double> _generateInitialPaid() {
    final Map<String, double> map = {};
    const entry = '54';
    final samplePaid = [
      400.0, 250.0, 800.0, 1500.0, 400.0, 250.0, 300.0, 200.0,
      100.0, 400.0, 50.0, 600.0, 650.0, 500.0, 150.0, 200.0,
    ];

    for (final sqn in CanteenConstants.squadrons) {
      for (int i = 0; i < CanteenConstants.rooms.length; i++) {
        final room = CanteenConstants.rooms[i];
        final key = '$entry|$sqn|$room';
        map[key] = samplePaid[i % samplePaid.length];
      }
    }
    return map;
  }

  /// Initial Ranks
  static Map<String, String> _generateInitialRanks() {
    final Map<String, String> map = {};
    const entry = '54';
    final sampleRanks = [
      'WO', 'WO', 'WO', 'WO', 'Sgt', 'Sgt', 'Sgt', 'Sgt',
      'Cpl', 'Cpl', 'Cpl', 'Rect Rep', 'Rect Rep', 'Rect Rep', 'Rect Rep', 'Rect Rep'
    ];

    for (final sqn in CanteenConstants.squadrons) {
      for (int i = 0; i < CanteenConstants.rooms.length; i++) {
        final room = CanteenConstants.rooms[i];
        final key = '$entry|$sqn|$room';
        map[key] = sampleRanks[i % sampleRanks.length];
      }
    }
    return map;
  }

  static Map<String, DailyRoomExpense> _generateDemoRecords() {
    final Map<String, DailyRoomExpense> result = {};
    final now = DateTime.now();
    const entry = '54';

    final demoSpending = [
      {'room': 'Room 1', 'amt': 420.0, 'items': 'Tea, Cream Biscuits, Snacks', 'rep': 'RCT 54101'},
      {'room': 'Room 2', 'amt': 380.0, 'items': 'Dry Cake, Banana, Milk', 'rep': 'RCT 54102'},
      {'room': 'Room 3', 'amt': 510.0, 'items': 'Snacks, Toilet Soap, Detergent', 'rep': 'RCT 54103'},
      {'room': 'Room 4', 'amt': 290.0, 'items': 'Tea, Biscuits', 'rep': 'RCT 54104'},
      {'room': 'Room 5', 'amt': 640.0, 'items': 'Juice, Special Dry Ration', 'rep': 'RCT 54105'},
      {'room': 'Room 6', 'amt': 350.0, 'items': 'Tea & Snacks for evening', 'rep': 'RCT 54106'},
    ];

    for (final sqn in CanteenConstants.squadrons) {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final d = now.subtract(Duration(days: dayOffset));
        final dStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

        for (final item in demoSpending) {
          final room = item['room'] as String;
          final amt = (item['amt'] as double) + (dayOffset * 15.0);
          final key = '$entry|$sqn|$room|$dStr';

          result[key] = DailyRoomExpense(
            id: key,
            entry: entry,
            squadron: sqn,
            room: room,
            date: d,
            amount: amt,
            recordedBy: dayOffset % 2 == 0 ? 'NCOIC' : 'JCOIC',
            representativeName: item['rep'] as String,
            itemsDescription: item['items'] as String,
            updatedAt: d,
          );
        }
      }
    }

    return result;
  }
}
