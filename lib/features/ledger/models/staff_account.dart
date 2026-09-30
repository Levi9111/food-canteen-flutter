import 'ledger_transaction.dart';

class StaffAccount {
  final String id;
  final String bdNo;       // e.g. "BD/48291"
  final String rank;       // e.g. "Sgt", "WO", "Cpl", "Sqn Ldr"
  final String name;
  final String office;     // e.g. "Admin Wing", "Trg Wg", "Station HQ", "MT Section"
  final double openingBalance;
  final double totalDebits;  // Canteen items consumed
  final double totalCredits; // Recovery / cash paid
  final double closingBalance;
  final List<LedgerTransaction> transactions;

  const StaffAccount({
    required this.id,
    required this.bdNo,
    required this.rank,
    required this.name,
    required this.office,
    this.openingBalance = 0.0,
    this.totalDebits = 0.0,
    this.totalCredits = 0.0,
    required this.closingBalance,
    this.transactions = const [],
  });

  bool get hasArrears => closingBalance > 0.01;
  bool get hasAdvance => closingBalance < -0.01;
  bool get isSettled => closingBalance.abs() <= 0.01;

  StaffAccount copyWith({
    String? id,
    String? bdNo,
    String? rank,
    String? name,
    String? office,
    double? openingBalance,
    double? totalDebits,
    double? totalCredits,
    double? closingBalance,
    List<LedgerTransaction>? transactions,
  }) {
    return StaffAccount(
      id: id ?? this.id,
      bdNo: bdNo ?? this.bdNo,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      office: office ?? this.office,
      openingBalance: openingBalance ?? this.openingBalance,
      totalDebits: totalDebits ?? this.totalDebits,
      totalCredits: totalCredits ?? this.totalCredits,
      closingBalance: closingBalance ?? this.closingBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}
