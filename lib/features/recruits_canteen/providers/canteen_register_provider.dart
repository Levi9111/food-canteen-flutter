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
    this.isLoading = false,
  });

  String makeKey(String entry, String squadron, String room, DateTime date) {
    final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$entry|$squadron|$room|$dStr';
  }

  DailyRoomExpense? getExpense(String entry, String squadron, String room, DateTime date) {
    return expenses[makeKey(entry, squadron, room, date)];
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
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final canteenRegisterProvider =
    NotifierProvider<CanteenRegisterNotifier, CanteenRegisterState>(
  CanteenRegisterNotifier.new,
);

class CanteenRegisterNotifier extends Notifier<CanteenRegisterState> {
  @override
  CanteenRegisterState build() {
    final now = DateTime.now();
    final initialState = CanteenRegisterState(
      selectedDate: now,
      selectedYear: now.year,
      selectedMonth: now.month,
    );
    Future.microtask(() => _loadFromPrefs());
    return initialState;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(CanteenConstants.prefsKeyEntries);
      final activeEntry = prefs.getString(CanteenConstants.prefsKeyActiveEntry) ?? CanteenConstants.defaultEntry;
      final activeManager = prefs.getString(CanteenConstants.prefsKeyActiveManager) ?? CanteenConstants.roleNcoic;
      final rawExpenses = prefs.getString(CanteenConstants.prefsKeyExpenses);

      Map<String, DailyRoomExpense> loadedExpenses = {};
      if (rawExpenses != null && rawExpenses.isNotEmpty) {
        final decoded = jsonDecode(rawExpenses) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          loadedExpenses[key] = DailyRoomExpense.fromJson(val as Map<String, dynamic>);
        });
      } else {
        // Pre-populate realistic demonstration records for Entry 54
        loadedExpenses = _generateDemoRecords();
      }

      state = state.copyWith(
        activeEntry: activeEntry,
        allEntries: entriesJson ?? state.allEntries,
        activeManager: activeManager,
        expenses: loadedExpenses,
      );
    } catch (_) {
      // Fallback to demo records on error
      state = state.copyWith(expenses: _generateDemoRecords());
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(CanteenConstants.prefsKeyEntries, state.allEntries);
      await prefs.setString(CanteenConstants.prefsKeyActiveEntry, state.activeEntry);
      await prefs.setString(CanteenConstants.prefsKeyActiveManager, state.activeManager);

      final Map<String, dynamic> serializable = {};
      state.expenses.forEach((k, v) => serializable[k] = v.toJson());
      await prefs.setString(CanteenConstants.prefsKeyExpenses, jsonEncode(serializable));
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

  static Map<String, DailyRoomExpense> _generateDemoRecords() {
    final Map<String, DailyRoomExpense> result = {};
    final now = DateTime.now();
    const entry = '54';

    // Demo entries across current month for all 4 squadrons and multiple rooms
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
