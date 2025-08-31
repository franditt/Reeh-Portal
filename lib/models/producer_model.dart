class Producer {
  final int id;
  final String googleUid;
  final String? organizationName;
  final String userName;
  final String email;
  final String? phone;
  final DateTime createdAt;

  Producer({
    required this.id,
    required this.googleUid,
    this.organizationName,
    required this.userName,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  factory Producer.fromJson(Map<String, dynamic> json) {
    return Producer(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      googleUid: json['google_uid'],
      organizationName: json['organization_name'],
      userName: json['user_name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_uid': googleUid,
      'organization_name': organizationName,
      'user_name': userName,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
