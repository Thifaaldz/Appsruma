import 'dart:convert';

class BoardingHouse {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String imageUrl;
  final List<String> imageUrls;
  final double defaultRoomPrice;
  final int totalRooms;
  final int vacantRooms;

  BoardingHouse({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.imageUrl,
    List<String>? imageUrls,
    this.defaultRoomPrice = 1500000,
    this.totalRooms = 0,
    this.vacantRooms = 0,
  }) : imageUrls = imageUrls ?? const [];

  factory BoardingHouse.fromJson(Map<String, dynamic> json) {
    final rooms = json['rooms'] as List? ?? [];
    final vacant = rooms.where((r) => r['status'] == 'available').length;
    final rawPrice = json['default_room_price'];
    return BoardingHouse(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      imageUrls: _parseImageUrls(json['image_urls'], json['image_url']),
      defaultRoomPrice: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse('$rawPrice') ?? 1500000,
      totalRooms: rooms.length,
      vacantRooms: vacant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'default_room_price': defaultRoomPrice,
    };
  }

  static List<String> _parseImageUrls(dynamic value, dynamic fallback) {
    final images = <String>[];
    if (value is List) {
      images.addAll(value.whereType<String>().where((item) => item.isNotEmpty));
    } else if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          images.addAll(
            decoded.whereType<String>().where((item) => item.isNotEmpty),
          );
        }
      } catch (_) {
        images.add(value);
      }
    }

    final fallbackImage = fallback is String ? fallback : '';
    if (images.isEmpty && fallbackImage.isNotEmpty) {
      images.add(fallbackImage);
    }
    return images;
  }
}
