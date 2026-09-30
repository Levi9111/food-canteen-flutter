class MonthlyAuditStatement {
  final String period;                // e.g. "September 2026"
  final DateTime generatedDate;
  final int totalRecruitsEnrolled;
  final int totalStaffEnrolled;
  final double recruitOpeningBalance;
  final double recruitTotalDebits;
  final double recruitTotalCredits;
  final double recruitClosingBalance;
  final double staffOpeningBalance;
  final double staffTotalDebits;
  final double staffTotalCredits;
  final double staffClosingBalance;
  final String auditedBy;
  final String approvedBy;

  const MonthlyAuditStatement({
    required this.period,
    required this.generatedDate,
    required this.totalRecruitsEnrolled,
    required this.totalStaffEnrolled,
    required this.recruitOpeningBalance,
    required this.recruitTotalDebits,
    required this.recruitTotalCredits,
    required this.recruitClosingBalance,
    required this.staffOpeningBalance,
    required this.staffTotalDebits,
    required this.staffTotalCredits,
    required this.staffClosingBalance,
    this.auditedBy = 'Accounts NCO, RTS BAF',
    this.approvedBy = 'Officer Commanding (OC) Admin / OIC Canteen',
  });

  double get grandOpeningBalance => recruitOpeningBalance + staffOpeningBalance;
  double get grandTotalDebits => recruitTotalDebits + staffTotalDebits;
  double get grandTotalCredits => recruitTotalCredits + staffTotalCredits;
  double get grandClosingBalance => recruitClosingBalance + staffClosingBalance;

  bool get isBalanced =>
      (grandOpeningBalance + grandTotalDebits - grandTotalCredits - grandClosingBalance).abs() < 0.01;
}
