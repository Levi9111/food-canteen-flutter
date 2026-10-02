class PStaffProfile {
  final String id;
  final String name;
  final String rank;
  final String bdNo;
  final String office;
  final double preDue;
  final double paid;

  const PStaffProfile({
    required this.id,
    required this.name,
    required this.rank,
    required this.bdNo,
    required this.office,
    this.preDue = 0.0,
    this.paid = 0.0,
  });

  PStaffProfile copyWith({
    String? id,
    String? name,
    String? rank,
    String? bdNo,
    String? office,
    double? preDue,
    double? paid,
  }) {
    return PStaffProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      bdNo: bdNo ?? this.bdNo,
      office: office ?? this.office,
      preDue: preDue ?? this.preDue,
      paid: paid ?? this.paid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'bdNo': bdNo,
    'office': office,
    'preDue': preDue,
    'paid': paid,
  };

  factory PStaffProfile.fromJson(Map<String, dynamic> json) => PStaffProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    rank: json['rank'] as String,
    bdNo: json['bdNo'] as String,
    office: json['office'] as String,
    preDue: (json['preDue'] as num?)?.toDouble() ?? 0.0,
    paid: (json['paid'] as num?)?.toDouble() ?? 0.0,
  );
}

class DailyStaffExpense {
  final String staffId;
  final String staffName;
  final String bdNo;
  final String rank;
  final String office;
  final DateTime date;
  final double amount;
  final String? particulars;
  final String recordedBy;
  final DateTime recordedAt;

  const DailyStaffExpense({
    required this.staffId,
    required this.staffName,
    required this.bdNo,
    required this.rank,
    required this.office,
    required this.date,
    required this.amount,
    this.particulars,
    required this.recordedBy,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'staffId': staffId,
    'staffName': staffName,
    'bdNo': bdNo,
    'rank': rank,
    'office': office,
    'date': date.toIso8601String(),
    'amount': amount,
    'particulars': particulars,
    'recordedBy': recordedBy,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory DailyStaffExpense.fromJson(Map<String, dynamic> json) => DailyStaffExpense(
    staffId: json['staffId'] as String,
    staffName: json['staffName'] as String,
    bdNo: json['bdNo'] as String,
    rank: json['rank'] as String,
    office: json['office'] as String,
    date: DateTime.parse(json['date'] as String),
    amount: (json['amount'] as num).toDouble(),
    particulars: json['particulars'] as String?,
    recordedBy: json['recordedBy'] as String,
    recordedAt: DateTime.parse(json['recordedAt'] as String),
  );
}

class StaffDailyRecord {
  final int dayNumber;
  final DateTime date;
  final double amount;
  final String? particulars;
  final String recordedBy;

  const StaffDailyRecord({
    required this.dayNumber,
    required this.date,
    required this.amount,
    this.particulars,
    required this.recordedBy,
  });
}

class StaffMonthlySummary {
  final PStaffProfile staff;
  final int year;
  final int month;
  final List<StaffDailyRecord> days;
  final double totalMonthlySpending;
  final double preDue;
  final double grandTotal;
  final double paid;
  final double netDue;
  final int activeDaysCount;

  const StaffMonthlySummary({
    required this.staff,
    required this.year,
    required this.month,
    required this.days,
    required this.totalMonthlySpending,
    required this.preDue,
    required this.grandTotal,
    required this.paid,
    required this.netDue,
    required this.activeDaysCount,
  });
}
