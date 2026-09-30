class LedgerTransaction {
  final String id;
  final String voucherNo;
  final DateTime date;
  final String category;
  final String description;
  final double debit;   // Canteen consumption / mess charges
  final double credit;  // Cash deposit / mess recovery
  final double runningBalance;
  final String authorizedBy;

  const LedgerTransaction({
    required this.id,
    required this.voucherNo,
    required this.date,
    required this.category,
    required this.description,
    this.debit = 0.0,
    this.credit = 0.0,
    required this.runningBalance,
    required this.authorizedBy,
  });

  bool get isDebit => debit > 0;
  bool get isCredit => credit > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'voucherNo': voucherNo,
    'date': date.toIso8601String(),
    'category': category,
    'description': description,
    'debit': debit,
    'credit': credit,
    'runningBalance': runningBalance,
    'authorizedBy': authorizedBy,
  };

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) =>
      LedgerTransaction(
        id: json['id'] ?? '',
        voucherNo: json['voucherNo'] ?? '',
        date: DateTime.parse(json['date']),
        category: json['category'] ?? 'General',
        description: json['description'] ?? '',
        debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
        credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
        runningBalance: (json['runningBalance'] as num?)?.toDouble() ?? 0.0,
        authorizedBy: json['authorizedBy'] ?? 'OIC Canteen',
      );
}
