class Tenant {
  final int id;
  final int userId;
  final int roomId;
  final String phone;
  final DateTime checkInDate;

  Tenant({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.phone,
    required this.checkInDate,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      phone: json['phone'],
      checkInDate: DateTime.parse(json['check_in_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'room_id': roomId,
      'phone': phone,
      'check_in_date': checkInDate.toIso8601String(),
    };
  }
}
