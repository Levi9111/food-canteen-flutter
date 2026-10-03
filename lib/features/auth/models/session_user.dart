class SessionUser {
  final String username;
  final String name;
  final String rank;
  final String role; // 'NCOIC', 'JCOIC', 'ADMIN'
  final String bdNo;

  const SessionUser({
    required this.username,
    required this.name,
    required this.rank,
    required this.role,
    required this.bdNo,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'rank': rank,
        'role': role,
        'bdNo': bdNo,
      };

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        username: json['username'] as String,
        name: json['name'] as String,
        rank: json['rank'] as String,
        role: json['role'] as String,
        bdNo: json['bdNo'] as String,
      );
}
