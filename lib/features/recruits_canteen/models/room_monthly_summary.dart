class RoomDayRecord {
  final int dayNumber;
  final DateTime date;
  final double amount;
  final String? itemsDescription;
  final String recordedBy;
  final String? representativeName;

  const RoomDayRecord({
    required this.dayNumber,
    required this.date,
    required this.amount,
    this.itemsDescription,
    this.recordedBy = 'NCOIC',
    this.representativeName,
  });
}

class RoomMonthlySummary {
  final String entry;
  final String squadron;
  final String room;
  final int year;
  final int month;
  final List<RoomDayRecord> days;

  const RoomMonthlySummary({
    required this.entry,
    required this.squadron,
    required this.room,
    required this.year,
    required this.month,
    required this.days,
  });

  double get totalMonthlySpending =>
      days.fold(0.0, (sum, d) => sum + d.amount);

  int get activeDaysCount =>
      days.where((d) => d.amount > 0).length;

  double get averageDailySpending =>
      activeDaysCount > 0 ? (totalMonthlySpending / activeDaysCount) : 0.0;
}
