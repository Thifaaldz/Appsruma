import 'dart:convert';

class Room {
  final int id;
  final int boardingHouseId;
  final String roomNumber;
  final double price;
  final String status;
  final bool useDefaultPrice;
  final List<String> imageUrls;

  Room({
    required this.id,
    required this.boardingHouseId,
    required this.roomNumber,
    required this.price,
    required this.status,
    this.useDefaultPrice = false,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? const [];

  factory Room.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    return Room(
      id: json['id'],
      boardingHouseId: json['boarding_house_id'],
      roomNumber: json['room_number'],
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse('$rawPrice') ?? 0,
      status: json['status'],
      useDefaultPrice: json['use_default_price'] == true,
      imageUrls: _parseImageUrls(json['image_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boarding_house_id': boardingHouseId,
      'room_number': roomNumber,
      'price': price,
      'status': status,
      'use_default_price': useDefaultPrice,
      'image_urls': imageUrls,
    };
  }

  static List<String> _parseImageUrls(dynamic value) {
    if (value is List) {
      return value
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded
              .whereType<String>()
              .where((item) => item.isNotEmpty)
              .toList();
        }
      } catch (_) {
        return [value];
      }
    }
    return const [];
  }
}
