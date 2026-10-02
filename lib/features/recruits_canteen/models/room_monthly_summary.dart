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

/// Official Pricing Management Monthly Summary for each room/entity
/// Aligned with Bangladesh Air Force (BAF) RTS Canteen Register Book
class RoomMonthlySummary {
  final String entry;
  final String squadron;
  final String room;
  final int year;
  final int month;
  final String rank;               // e.g. "Rect Rep", "Sgt", "Cpl", "WO", "Civ"
  final String? representativeName;// Representative in-charge
  final double preDue;             // Previous Due carried forward from prior month (Tk)
  final double paid;               // Amount settled/paid in current cycle (Tk)
  final List<RoomDayRecord> days;  // Daily entries (Day 1 to 31)

  const RoomMonthlySummary({
    required this.entry,
    required this.squadron,
    required this.room,
    required this.year,
    required this.month,
    this.rank = 'Rect Rep',
    this.representativeName,
    this.preDue = 0.0,
    this.paid = 0.0,
    required this.days,
  });

  /// Total spending across all days in the current month
  double get totalMonthlySpending =>
      days.fold(0.0, (sum, d) => sum + d.amount);

  /// Grand Total = Previous Due + Current Month Spending
  double get grandTotal => preDue + totalMonthlySpending;

  /// Net Closing Due = Grand Total - Paid
  double get netDue => grandTotal - paid;

  /// Number of days with non-zero spending
  int get activeDaysCount =>
      days.where((d) => d.amount > 0).length;

  /// Average daily spending on active days
  double get averageDailySpending =>
      activeDaysCount > 0 ? (totalMonthlySpending / activeDaysCount) : 0.0;
}
