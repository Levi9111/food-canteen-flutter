import 'ledger_transaction.dart';

class RecruitAccount {
  final String id;
  final String intake;      // e.g. "Intake 52"
  final String squadron;    // e.g. "Squadron A (Sher-e-Bangla)"
  final String flight;      // e.g. "Flight 1"
  final String recruitNo;   // e.g. "RCT-52101"
  final String name;
  final double openingBalance;
  final double totalDebits;  // Total canteen consumption
  final double totalCredits; // Total cash deposits / pay deduction
  final double closingBalance;
  final List<LedgerTransaction> transactions;

  const RecruitAccount({
    required this.id,
    required this.intake,
    required this.squadron,
    required this.flight,
    required this.recruitNo,
    required this.name,
    this.openingBalance = 0.0,
    this.totalDebits = 0.0,
    this.totalCredits = 0.0,
    required this.closingBalance,
    this.transactions = const [],
  });

  bool get hasArrears => closingBalance > 0.01;
  bool get hasAdvance => closingBalance < -0.01;
  bool get isSettled => closingBalance.abs() <= 0.01;

  RecruitAccount copyWith({
    String? id,
    String? intake,
    String? squadron,
    String? flight,
    String? recruitNo,
    String? name,
    double? openingBalance,
    double? totalDebits,
    double? totalCredits,
    double? closingBalance,
    List<LedgerTransaction>? transactions,
  }) {
    return RecruitAccount(
      id: id ?? this.id,
      intake: intake ?? this.intake,
      squadron: squadron ?? this.squadron,
      flight: flight ?? this.flight,
      recruitNo: recruitNo ?? this.recruitNo,
      name: name ?? this.name,
      openingBalance: openingBalance ?? this.openingBalance,
      totalDebits: totalDebits ?? this.totalDebits,
      totalCredits: totalCredits ?? this.totalCredits,
      closingBalance: closingBalance ?? this.closingBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}
