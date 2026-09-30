class DailyRoomExpense {
  final String id;
  final String entry;               // e.g. "54"
  final String squadron;            // e.g. "Sadruddin"
  final String room;                // e.g. "Room 1"
  final DateTime date;              // Day of expenditure
  final double amount;              // Price value in Tk
  final String recordedBy;          // NCOIC or JCOIC
  final String? representativeName; // Room representative
  final String? itemsDescription;   // Items picked by the room
  final DateTime updatedAt;

  const DailyRoomExpense({
    required this.id,
    required this.entry,
    required this.squadron,
    required this.room,
    required this.date,
    required this.amount,
    required this.recordedBy,
    this.representativeName,
    this.itemsDescription,
    required this.updatedAt,
  });

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  String get roomKey => '$entry|$squadron|$room|$dateKey';

  Map<String, dynamic> toJson() => {
    'id': id,
    'entry': entry,
    'squadron': squadron,
    'room': room,
    'date': date.toIso8601String(),
    'amount': amount,
    'recordedBy': recordedBy,
    'representativeName': representativeName,
    'itemsDescription': itemsDescription,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DailyRoomExpense.fromJson(Map<String, dynamic> json) => DailyRoomExpense(
    id: json['id'] ?? '',
    entry: json['entry'] ?? '54',
    squadron: json['squadron'] ?? '',
    room: json['room'] ?? '',
    date: DateTime.parse(json['date']),
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    recordedBy: json['recordedBy'] ?? 'NCOIC',
    representativeName: json['representativeName'],
    itemsDescription: json['itemsDescription'],
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
  );

  DailyRoomExpense copyWith({
    String? id,
    String? entry,
    String? squadron,
    String? room,
    DateTime? date,
    double? amount,
    String? recordedBy,
    String? representativeName,
    String? itemsDescription,
    DateTime? updatedAt,
  }) {
    return DailyRoomExpense(
      id: id ?? this.id,
      entry: entry ?? this.entry,
      squadron: squadron ?? this.squadron,
      room: room ?? this.room,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      recordedBy: recordedBy ?? this.recordedBy,
      representativeName: representativeName ?? this.representativeName,
      itemsDescription: itemsDescription ?? this.itemsDescription,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
