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
    this.roomNumber = '',
    this.price = 0,
    this.status = 'available',
    this.useDefaultPrice = false,
    this.imageUrls = const [],
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      boardingHouseId: json['boarding_house_id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'available',
      useDefaultPrice: json['use_default_price'] ?? false,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boarding_house_id': boardingHouseId,
      'room_number': roomNumber,
      'price': price,
      'status': status,
      'use_default_price': useDefaultPrice,
      'image_urls': imageUrls,
    };
  }
}
