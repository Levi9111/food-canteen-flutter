import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ledger_transaction.dart';
import '../models/recruit_account.dart';
import '../models/staff_account.dart';

// --- Recruits State & Notifier ---

class RecruitsLedgerState {
  final List<RecruitAccount> allRecruits;
  final String selectedIntake;
  final String selectedSquadron;
  final String searchQuery;

  const RecruitsLedgerState({
    required this.allRecruits,
    this.selectedIntake = 'All Intakes',
    this.selectedSquadron = 'All Squadrons',
    this.searchQuery = '',
  });

  List<String> get availableIntakes {
    final intakes = allRecruits.map((e) => e.intake).toSet().toList();
    return ['All Intakes', ...intakes];
  }

  List<String> get availableSquadrons {
    final squadrons = allRecruits.map((e) => e.squadron).toSet().toList();
    return ['All Squadrons', ...squadrons];
  }

  List<RecruitAccount> get filteredRecruits {
    return allRecruits.where((r) {
      final matchesIntake =
          selectedIntake == 'All Intakes' || r.intake == selectedIntake;
      final matchesSquadron =
          selectedSquadron == 'All Squadrons' || r.squadron == selectedSquadron;
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          r.recruitNo.toLowerCase().contains(q) ||
          r.name.toLowerCase().contains(q) ||
          r.flight.toLowerCase().contains(q);
      return matchesIntake && matchesSquadron && matchesSearch;
    }).toList();
  }

  double get totalDebits =>
      filteredRecruits.fold(0.0, (sum, r) => sum + r.totalDebits);

  double get totalCredits =>
      filteredRecruits.fold(0.0, (sum, r) => sum + r.totalCredits);

  double get totalOutstandingDues =>
      filteredRecruits.fold(0.0, (sum, r) => sum + (r.closingBalance > 0 ? r.closingBalance : 0.0));

  RecruitsLedgerState copyWith({
    List<RecruitAccount>? allRecruits,
    String? selectedIntake,
    String? selectedSquadron,
    String? searchQuery,
  }) {
    return RecruitsLedgerState(
      allRecruits: allRecruits ?? this.allRecruits,
      selectedIntake: selectedIntake ?? this.selectedIntake,
      selectedSquadron: selectedSquadron ?? this.selectedSquadron,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final recruitsLedgerProvider =
    NotifierProvider<RecruitsLedgerNotifier, RecruitsLedgerState>(
  RecruitsLedgerNotifier.new,
);

class RecruitsLedgerNotifier extends Notifier<RecruitsLedgerState> {
  @override
  RecruitsLedgerState build() {
    return RecruitsLedgerState(allRecruits: _generateInitialRecruits());
  }

  void setIntake(String intake) {
    state = state.copyWith(selectedIntake: intake);
  }

  void setSquadron(String squadron) {
    state = state.copyWith(selectedSquadron: squadron);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void postTransaction({
    required String recruitId,
    required String voucherNo,
    required String category,
    required String description,
    required double debit,
    required double credit,
    required String authorizedBy,
  }) {
    final updatedList = state.allRecruits.map((recruit) {
      if (recruit.id != recruitId) return recruit;

      final newTotalDebits = recruit.totalDebits + debit;
      final newTotalCredits = recruit.totalCredits + credit;
      final newClosingBalance =
          recruit.openingBalance + newTotalDebits - newTotalCredits;

      final newTx = LedgerTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        voucherNo: voucherNo,
        date: DateTime.now(),
        category: category,
        description: description,
        debit: debit,
        credit: credit,
        runningBalance: newClosingBalance,
        authorizedBy: authorizedBy,
      );

      return recruit.copyWith(
        totalDebits: newTotalDebits,
        totalCredits: newTotalCredits,
        closingBalance: newClosingBalance,
        transactions: [newTx, ...recruit.transactions],
      );
    }).toList();

    state = state.copyWith(allRecruits: updatedList);
  }

  static List<RecruitAccount> _generateInitialRecruits() {
    return [
      RecruitAccount(
        id: 'r1',
        intake: 'Intake 52',
        squadron: 'Squadron A (Sher-e-Bangla)',
        flight: 'Flight 1',
        recruitNo: 'RCT-52101',
        name: 'Md. Tariqul Islam',
        openingBalance: 0.0,
        totalDebits: 2850.0,
        totalCredits: 2000.0,
        closingBalance: 850.0,
        transactions: [
          LedgerTransaction(
            id: 't1',
            voucherNo: 'VCH-RTS-8901',
            date: DateTime.now().subtract(const Duration(days: 3)),
            category: 'Canteen Consumption',
            description: 'Dry ration and breakfast mess bill',
            debit: 1450.0,
            credit: 0.0,
            runningBalance: 1450.0,
            authorizedBy: 'Canteen NCO',
          ),
          LedgerTransaction(
            id: 't2',
            voucherNo: 'VCH-RTS-8942',
            date: DateTime.now().subtract(const Duration(days: 2)),
            category: 'Tea & Snacks',
            description: 'Mid-break canteen tokens',
            debit: 1400.0,
            credit: 0.0,
            runningBalance: 2850.0,
            authorizedBy: 'Canteen NCO',
          ),
          LedgerTransaction(
            id: 't3',
            voucherNo: 'REC-RTS-4102',
            date: DateTime.now().subtract(const Duration(days: 1)),
            category: 'Pay Recovery',
            description: 'Cash deposit via Squadron Accountant',
            debit: 0.0,
            credit: 2000.0,
            runningBalance: 850.0,
            authorizedBy: 'Accounts NCO',
          ),
        ],
      ),
      RecruitAccount(
        id: 'r2',
        intake: 'Intake 52',
        squadron: 'Squadron A (Sher-e-Bangla)',
        flight: 'Flight 1',
        recruitNo: 'RCT-52102',
        name: 'Tanvir Ahmed',
        openingBalance: 120.0,
        totalDebits: 3100.0,
        totalCredits: 3220.0,
        closingBalance: 0.0,
        transactions: [
          LedgerTransaction(
            id: 't4',
            voucherNo: 'REC-RTS-4103',
            date: DateTime.now().subtract(const Duration(days: 1)),
            category: 'Settlement',
            description: 'Full mess dues cleared',
            debit: 0.0,
            credit: 3220.0,
            runningBalance: 0.0,
            authorizedBy: 'Accounts NCO',
          ),
        ],
      ),
      RecruitAccount(
        id: 'r3',
        intake: 'Intake 52',
        squadron: 'Squadron B (Suhrawardy)',
        flight: 'Flight 2',
        recruitNo: 'RCT-52204',
        name: 'Rashedul Hasan',
        openingBalance: 0.0,
        totalDebits: 1950.0,
        totalCredits: 1000.0,
        closingBalance: 950.0,
        transactions: [
          LedgerTransaction(
            id: 't5',
            voucherNo: 'VCH-RTS-9011',
            date: DateTime.now().subtract(const Duration(days: 4)),
            category: 'Canteen Store',
            description: 'Toiletries & Mess essentials',
            debit: 1950.0,
            credit: 0.0,
            runningBalance: 1950.0,
            authorizedBy: 'Canteen NCO',
          ),
        ],
      ),
      RecruitAccount(
        id: 'r4',
        intake: 'Intake 52',
        squadron: 'Squadron C (Fazlul Huq)',
        flight: 'Flight 3',
        recruitNo: 'RCT-52315',
        name: 'Saiful Karim',
        openingBalance: 0.0,
        totalDebits: 2200.0,
        totalCredits: 2200.0,
        closingBalance: 0.0,
        transactions: [],
      ),
      RecruitAccount(
        id: 'r5',
        intake: 'Intake 51',
        squadron: 'Squadron A (Sher-e-Bangla)',
        flight: 'Flight 4',
        recruitNo: 'RCT-51088',
        name: 'Shahadat Hossain',
        openingBalance: 450.0,
        totalDebits: 1800.0,
        totalCredits: 1500.0,
        closingBalance: 750.0,
        transactions: [],
      ),
    ];
  }
}

// --- Permanent Staff State & Notifier ---

class StaffLedgerState {
  final List<StaffAccount> allStaff;
  final String selectedOffice;
  final String searchQuery;

  const StaffLedgerState({
    required this.allStaff,
    this.selectedOffice = 'All Offices',
    this.searchQuery = '',
  });

  List<String> get availableOffices {
    final offices = allStaff.map((e) => e.office).toSet().toList();
    return ['All Offices', ...offices];
  }

  List<StaffAccount> get filteredStaff {
    return allStaff.where((s) {
      final matchesOffice =
          selectedOffice == 'All Offices' || s.office == selectedOffice;
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          s.bdNo.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q) ||
          s.rank.toLowerCase().contains(q) ||
          s.office.toLowerCase().contains(q);
      return matchesOffice && matchesSearch;
    }).toList();
  }

  double get totalDebits =>
      filteredStaff.fold(0.0, (sum, s) => sum + s.totalDebits);

  double get totalCredits =>
      filteredStaff.fold(0.0, (sum, s) => sum + s.totalCredits);

  double get totalOutstandingDues =>
      filteredStaff.fold(0.0, (sum, s) => sum + (s.closingBalance > 0 ? s.closingBalance : 0.0));

  StaffLedgerState copyWith({
    List<StaffAccount>? allStaff,
    String? selectedOffice,
    String? searchQuery,
  }) {
    return StaffLedgerState(
      allStaff: allStaff ?? this.allStaff,
      selectedOffice: selectedOffice ?? this.selectedOffice,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final staffLedgerProvider =
    NotifierProvider<StaffLedgerNotifier, StaffLedgerState>(
  StaffLedgerNotifier.new,
);

class StaffLedgerNotifier extends Notifier<StaffLedgerState> {
  @override
  StaffLedgerState build() {
    return StaffLedgerState(allStaff: _generateInitialStaff());
  }

  void setOffice(String office) {
    state = state.copyWith(selectedOffice: office);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void postTransaction({
    required String staffId,
    required String voucherNo,
    required String category,
    required String description,
    required double debit,
    required double credit,
    required String authorizedBy,
  }) {
    final updatedList = state.allStaff.map((staff) {
      if (staff.id != staffId) return staff;

      final newTotalDebits = staff.totalDebits + debit;
      final newTotalCredits = staff.totalCredits + credit;
      final newClosingBalance =
          staff.openingBalance + newTotalDebits - newTotalCredits;

      final newTx = LedgerTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        voucherNo: voucherNo,
        date: DateTime.now(),
        category: category,
        description: description,
        debit: debit,
        credit: credit,
        runningBalance: newClosingBalance,
        authorizedBy: authorizedBy,
      );

      return staff.copyWith(
        totalDebits: newTotalDebits,
        totalCredits: newTotalCredits,
        closingBalance: newClosingBalance,
        transactions: [newTx, ...staff.transactions],
      );
    }).toList();

    state = state.copyWith(allStaff: updatedList);
  }

  static List<StaffAccount> _generateInitialStaff() {
    return [
      StaffAccount(
        id: 's1',
        bdNo: 'BD/48291',
        rank: 'Sgt',
        name: 'K. M. Mizanur Rahman',
        office: 'Training Wing (RTS)',
        openingBalance: 0.0,
        totalDebits: 4500.0,
        totalCredits: 4000.0,
        closingBalance: 500.0,
        transactions: [
          LedgerTransaction(
            id: 'st1',
            voucherNo: 'ST-RTS-102',
            date: DateTime.now().subtract(const Duration(days: 5)),
            category: 'Monthly Dining Charge',
            description: 'Staff mess monthly tea & refreshment bill',
            debit: 4500.0,
            credit: 0.0,
            runningBalance: 4500.0,
            authorizedBy: 'Canteen NCO',
          ),
          LedgerTransaction(
            id: 'st2',
            voucherNo: 'ST-REC-508',
            date: DateTime.now().subtract(const Duration(days: 1)),
            category: 'Salary Deduction',
            description: 'Direct accounts recovery via Base Accounts',
            debit: 0.0,
            credit: 4000.0,
            runningBalance: 500.0,
            authorizedBy: 'Base Accounts',
          ),
        ],
      ),
      StaffAccount(
        id: 's2',
        bdNo: 'BD/52109',
        rank: 'Cpl',
        name: 'Mahfuzur Rahman',
        office: 'Admin Wing (RTS)',
        openingBalance: 0.0,
        totalDebits: 3200.0,
        totalCredits: 3200.0,
        closingBalance: 0.0,
        transactions: [],
      ),
      StaffAccount(
        id: 's3',
        bdNo: 'BD/39104',
        rank: 'Master WO',
        name: 'Golam Sarwar',
        office: 'Station HQ (RTS)',
        openingBalance: 150.0,
        totalDebits: 5800.0,
        totalCredits: 4500.0,
        closingBalance: 1450.0,
        transactions: [
          LedgerTransaction(
            id: 'st3',
            voucherNo: 'ST-RTS-118',
            date: DateTime.now().subtract(const Duration(days: 2)),
            category: 'Canteen Store',
            description: 'Dry ration and officer mess items',
            debit: 5800.0,
            credit: 0.0,
            runningBalance: 5950.0,
            authorizedBy: 'Canteen NCO',
          ),
        ],
      ),
      StaffAccount(
        id: 's4',
        bdNo: 'BD/60211',
        rank: 'JWO',
        name: 'Ashraful Alam',
        office: 'Motor Transport (MT)',
        openingBalance: 0.0,
        totalDebits: 2600.0,
        totalCredits: 2600.0,
        closingBalance: 0.0,
        transactions: [],
      ),
      StaffAccount(
        id: 's5',
        bdNo: 'BD/71003',
        rank: 'Sqn Ldr',
        name: 'Farhan Kabir',
        office: 'Officer Mess / OC Canteen',
        openingBalance: 0.0,
        totalDebits: 6200.0,
        totalCredits: 6200.0,
        closingBalance: 0.0,
        transactions: [],
      ),
    ];
  }
}
