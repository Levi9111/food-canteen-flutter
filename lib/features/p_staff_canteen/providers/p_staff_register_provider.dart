import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/p_staff_constants.dart';
import '../models/p_staff_models.dart';

class PStaffRegisterState {
  final List<PStaffProfile> staffProfiles;
  final Map<String, DailyStaffExpense> expenses;
  final DateTime selectedDate;
  final String selectedOffice;
  final int selectedYear;
  final int selectedMonth;
  final String? selectedStaffId;
  final String activeManager;
  final String searchQuery;

  const PStaffRegisterState({
    required this.staffProfiles,
    required this.expenses,
    required this.selectedDate,
    required this.selectedOffice,
    required this.selectedYear,
    required this.selectedMonth,
    this.selectedStaffId,
    required this.activeManager,
    this.searchQuery = '',
  });

  PStaffRegisterState copyWith({
    List<PStaffProfile>? staffProfiles,
    Map<String, DailyStaffExpense>? expenses,
    DateTime? selectedDate,
    String? selectedOffice,
    int? selectedYear,
    int? selectedMonth,
    String? selectedStaffId,
    String? activeManager,
    String? searchQuery,
  }) {
    return PStaffRegisterState(
      staffProfiles: staffProfiles ?? this.staffProfiles,
      expenses: expenses ?? this.expenses,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedOffice: selectedOffice ?? this.selectedOffice,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedStaffId: selectedStaffId ?? this.selectedStaffId,
      activeManager: activeManager ?? this.activeManager,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<PStaffProfile> get filteredStaffProfiles {
    return staffProfiles.where((staff) {
      final matchesOffice = selectedOffice == 'ALL OFFICES' || staff.office == selectedOffice;
      final q = searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          staff.name.toLowerCase().contains(q) ||
          staff.bdNo.toLowerCase().contains(q) ||
          staff.rank.toLowerCase().contains(q) ||
          staff.office.toLowerCase().contains(q);
      return matchesOffice && matchesQuery;
    }).toList();
  }

  String _expenseKey(String staffId, DateTime date) {
    final d = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${d}_$staffId';
  }

  DailyStaffExpense? getExpense(String staffId, DateTime date) {
    return expenses[_expenseKey(staffId, date)];
  }

  double getStaffDayTotal(DateTime date) {
    double total = 0.0;
    for (final staff in staffProfiles) {
      final exp = getExpense(staff.id, date);
      if (exp != null) total += exp.amount;
    }
    return total;
  }

  double getStaffMonthTotal(String staffId, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    double total = 0.0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final exp = getExpense(staffId, date);
      if (exp != null) total += exp.amount;
    }
    return total;
  }

  PStaffProfile? getStaffById(String id) {
    try {
      return staffProfiles.firstWhere((s) => s.id == id);
    } catch (_) {
      return staffProfiles.isNotEmpty ? staffProfiles.first : null;
    }
  }

  double getStaffPreDue(String staffId) {
    final staff = getStaffById(staffId);
    return staff?.preDue ?? 0.0;
  }

  double getStaffPaid(String staffId) {
    final staff = getStaffById(staffId);
    return staff?.paid ?? 0.0;
  }

  double getAllStaffPreDueTotal() {
    return filteredStaffProfiles.fold(0.0, (sum, s) => sum + s.preDue);
  }

  double getAllStaffPaidTotal() {
    return filteredStaffProfiles.fold(0.0, (sum, s) => sum + s.paid);
  }

  double getAllStaffMonthGrandTotal(int year, int month) {
    double total = 0.0;
    for (final staff in filteredStaffProfiles) {
      total += getStaffMonthTotal(staff.id, year, month);
    }
    return total;
  }

  double getAllStaffNetDueTotal(int year, int month) {
    double preDueTotal = getAllStaffPreDueTotal();
    double monthTotal = getAllStaffMonthGrandTotal(year, month);
    double paidTotal = getAllStaffPaidTotal();
    return (preDueTotal + monthTotal) - paidTotal;
  }

  StaffMonthlySummary getStaffMonthlySummary(String staffId, int year, int month) {
    final staff = getStaffById(staffId) ??
        PStaffProfile(id: staffId, name: 'Unknown', rank: 'Staff', bdNo: 'BD/00000', office: 'General');
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<StaffDailyRecord> records = [];
    double monthlySpending = 0.0;
    int activeDays = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final exp = getExpense(staffId, date);
      final amt = exp?.amount ?? 0.0;
      if (amt > 0) activeDays++;
      monthlySpending += amt;

      records.add(
        StaffDailyRecord(
          dayNumber: day,
          date: date,
          amount: amt,
          particulars: exp?.particulars,
          recordedBy: exp?.recordedBy ?? activeManager,
        ),
      );
    }

    final grandTotal = staff.preDue + monthlySpending;
    final netDue = grandTotal - staff.paid;

    return StaffMonthlySummary(
      staff: staff,
      year: year,
      month: month,
      days: records,
      totalMonthlySpending: monthlySpending,
      preDue: staff.preDue,
      grandTotal: grandTotal,
      paid: staff.paid,
      netDue: netDue,
      activeDaysCount: activeDays,
    );
  }
}

class PStaffRegisterNotifier extends Notifier<PStaffRegisterState> {
  static const String _storageKeyStaff = 'p_staff_profiles_v1';
  static const String _storageKeyExpenses = 'p_staff_expenses_v1';

  @override
  PStaffRegisterState build() {
    final now = DateTime.now();
    final initialState = PStaffRegisterState(
      staffProfiles: _defaultStaffProfiles,
      expenses: {},
      selectedDate: now,
      selectedOffice: 'ALL OFFICES',
      selectedYear: now.year,
      selectedMonth: now.month,
      selectedStaffId: _defaultStaffProfiles.isNotEmpty ? _defaultStaffProfiles.first.id : null,
      activeManager: PStaffConstants.roleNcoic,
    );
    Future.microtask(() => _loadFromStorage());
    return initialState;
  }

  static final List<PStaffProfile> _defaultStaffProfiles = [
    const PStaffProfile(
      id: 'staff_1',
      name: 'Tariqul Islam',
      rank: 'Sgt',
      bdNo: 'BD/48291',
      office: 'Admin Wing',
      preDue: 450.0,
      paid: 500.0,
    ),
    const PStaffProfile(
      id: 'staff_2',
      name: 'Humayun Kabir',
      rank: 'MWO',
      bdNo: 'BD/39102',
      office: 'Training Wing (RTS)',
      preDue: 0.0,
      paid: 0.0,
    ),
    const PStaffProfile(
      id: 'staff_3',
      name: 'Mahbubur Rahman',
      rank: 'WO',
      bdNo: 'BD/42150',
      office: 'Station HQ',
      preDue: 280.0,
      paid: 200.0,
    ),
    const PStaffProfile(
      id: 'staff_4',
      name: 'Nazmul Hasan',
      rank: 'Cpl',
      bdNo: 'BD/58190',
      office: 'Logistics Squadron',
      preDue: 150.0,
      paid: 150.0,
    ),
    const PStaffProfile(
      id: 'staff_5',
      name: 'Kamrul Ahsan',
      rank: 'Flt Sgt',
      bdNo: 'BD/44120',
      office: 'MT Squadron',
      preDue: 0.0,
      paid: 0.0,
    ),
    const PStaffProfile(
      id: 'staff_6',
      name: 'Dr. Shariful Alam',
      rank: 'Sqn Ldr',
      bdNo: 'BD/81204',
      office: 'Medical Squadron',
      preDue: 600.0,
      paid: 600.0,
    ),
    const PStaffProfile(
      id: 'staff_7',
      name: 'Anisur Rahman',
      rank: 'LAC',
      bdNo: 'BD/69201',
      office: 'Canteen Staff',
      preDue: 90.0,
      paid: 0.0,
    ),
    const PStaffProfile(
      id: 'staff_8',
      name: 'Moniruzzaman',
      rank: 'Civilian',
      bdNo: 'CIV/1042',
      office: 'Accounts Section',
      preDue: 0.0,
      paid: 0.0,
    ),
  ];

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final staffJson = prefs.getString(_storageKeyStaff);
      List<PStaffProfile> loadedStaff = _defaultStaffProfiles;
      if (staffJson != null) {
        final List decoded = jsonDecode(staffJson);
        loadedStaff = decoded.map((e) => PStaffProfile.fromJson(e)).toList();
      }

      final expJson = prefs.getString(_storageKeyExpenses);
      final Map<String, DailyStaffExpense> loadedExp = {};
      if (expJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(expJson);
        decoded.forEach((key, val) {
          loadedExp[key] = DailyStaffExpense.fromJson(val);
        });
      }

      state = state.copyWith(
        staffProfiles: loadedStaff,
        expenses: loadedExp,
        selectedStaffId: loadedStaff.isNotEmpty ? loadedStaff.first.id : null,
      );
    } catch (_) {
      // Graceful fallback to initial state
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffJson = jsonEncode(state.staffProfiles.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKeyStaff, staffJson);

      final expJson = jsonEncode(state.expenses.map((k, v) => MapEntry(k, v.toJson())));
      await prefs.setString(_storageKeyExpenses, expJson);
    } catch (_) {}
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedOffice(String office) {
    state = state.copyWith(selectedOffice: office);
  }

  void setSelectedMonth(int year, int month) {
    state = state.copyWith(selectedYear: year, selectedMonth: month);
  }

  void setSelectedStaffId(String id) {
    state = state.copyWith(selectedStaffId: id);
  }

  void setActiveManager(String manager) {
    state = state.copyWith(activeManager: manager);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addNewStaff({
    required String name,
    required String rank,
    required String bdNo,
    required String office,
    double preDue = 0.0,
  }) async {
    final id = 'staff_${DateTime.now().millisecondsSinceEpoch}';
    final newStaff = PStaffProfile(
      id: id,
      name: name,
      rank: rank,
      bdNo: bdNo,
      office: office,
      preDue: preDue,
      paid: 0.0,
    );

    final updated = [...state.staffProfiles, newStaff];
    state = state.copyWith(staffProfiles: updated, selectedStaffId: id);
    await _saveToStorage();
  }

  Future<void> updateStaff({
    required String id,
    required String name,
    required String rank,
    required String bdNo,
    required String office,
    double? preDue,
    double? paid,
  }) async {
    final updated = state.staffProfiles.map((s) {
      if (s.id == id) {
        return s.copyWith(
          name: name,
          rank: rank,
          bdNo: bdNo,
          office: office,
          preDue: preDue ?? s.preDue,
          paid: paid ?? s.paid,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(staffProfiles: updated);
    await _saveToStorage();
  }

  Future<void> updateStaffPreDue(String id, double preDue) async {
    final updated = state.staffProfiles.map((s) {
      if (s.id == id) return s.copyWith(preDue: preDue);
      return s;
    }).toList();
    state = state.copyWith(staffProfiles: updated);
    await _saveToStorage();
  }

  Future<void> updateStaffPaid(String id, double paid) async {
    final updated = state.staffProfiles.map((s) {
      if (s.id == id) return s.copyWith(paid: paid);
      return s;
    }).toList();
    state = state.copyWith(staffProfiles: updated);
    await _saveToStorage();
  }

  Future<void> deleteStaff(String id) async {
    final updated = state.staffProfiles.where((s) => s.id != id).toList();
    state = state.copyWith(
      staffProfiles: updated,
      selectedStaffId: updated.isNotEmpty ? updated.first.id : null,
    );
    await _saveToStorage();
  }

  Future<void> recordStaffExpense({
    required String staffId,
    required double amount,
    DateTime? date,
    String? particulars,
  }) async {
    final targetDate = date ?? state.selectedDate;
    final staff = state.getStaffById(staffId);
    if (staff == null) return;

    final key = state._expenseKey(staffId, targetDate);
    final updatedExpenses = Map<String, DailyStaffExpense>.from(state.expenses);

    if (amount <= 0.0) {
      updatedExpenses.remove(key);
    } else {
      updatedExpenses[key] = DailyStaffExpense(
        staffId: staffId,
        staffName: staff.name,
        bdNo: staff.bdNo,
        rank: staff.rank,
        office: staff.office,
        date: targetDate,
        amount: amount,
        particulars: particulars,
        recordedBy: state.activeManager,
        recordedAt: DateTime.now(),
      );
    }

    state = state.copyWith(expenses: updatedExpenses);
    await _saveToStorage();
  }
}

final pStaffRegisterProvider =
    NotifierProvider<PStaffRegisterNotifier, PStaffRegisterState>(
  PStaffRegisterNotifier.new,
);
