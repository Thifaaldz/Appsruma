class Tenant {
  final int id;
  final int userId;
  final int roomId;
  final String phone;
  final String gender;
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final String? userName;
  final String? userEmail;
  final String? roomNumber;

  // Fields for optional account creation during assignment
  final String? name;
  final String? email;
  final String? password;

  Tenant({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.phone,
    this.gender = '',
    required this.checkInDate,
    this.checkOutDate,
    this.userName,
    this.userEmail,
    this.roomNumber,
    this.name,
    this.email,
    this.password,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? userEmail;
    String? roomNumber;
    if (json['user'] != null) {
      userName = json['user']['name'];
      userEmail = json['user']['email'];
    }
    if (json['room'] != null) {
      roomNumber = json['room']['room_number'];
    }
    return Tenant(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      checkInDate: json['check_in_date'] != null
          ? DateTime.parse(json['check_in_date'])
          : DateTime.now(),
      checkOutDate: json['check_out_date'] != null &&
              json['check_out_date'] != '0001-01-01T00:00:00Z'
          ? DateTime.parse(json['check_out_date'])
          : null,
      userName: userName,
      userEmail: userEmail,
      roomNumber: roomNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'room_id': roomId,
      'phone': phone,
      'gender': gender,
      'check_in_date': checkInDate.toUtc().toIso8601String(),
      if (checkOutDate != null) 'check_out_date': checkOutDate!.toUtc().toIso8601String(),
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    };
  }
}
