class SessionUser {
  final String? id;
  final String username;
  final String name;
  final String rank;
  final String role; // 'NCOIC', 'JCOIC', 'ADMIN'
  final String bdNo;
  final String? trade;

  const SessionUser({
    this.id,
    required this.username,
    required this.name,
    required this.rank,
    required this.role,
    required this.bdNo,
    this.trade,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'username': username,
        'name': name,
        'rank': rank,
        'role': role,
        'bdNo': bdNo,
        if (trade != null) 'trade': trade,
      };

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        id: json['id'] as String? ?? json['userId'] as String? ?? json['_id'] as String?,
        username: json['username'] as String? ?? '',
        name: json['name'] as String? ?? '',
        rank: json['rank'] as String? ?? 'Sgt',
        role: json['role'] as String? ?? 'NCOIC',
        bdNo: json['bdNo'] as String? ?? '',
        trade: json['trade'] as String?,
      );
}
