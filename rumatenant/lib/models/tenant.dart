import 'user.dart';
import 'room.dart';

class Tenant {
  final int id;
  final int userId;
  final int roomId;
  final String phone;
  final String gender;
  final String checkInDate;
  final String checkOutDate;
  final User? user;
  final Room? room;

  Tenant({
    required this.id,
    this.userId = 0,
    this.roomId = 0,
    this.phone = '',
    this.gender = '',
    this.checkInDate = '',
    this.checkOutDate = '',
    this.user,
    this.room,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
    );
  }
}
