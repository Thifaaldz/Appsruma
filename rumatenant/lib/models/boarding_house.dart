class BoardingHouse {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String imageUrl;
  final List<String> imageUrls;
  final double defaultRoomPrice;

  BoardingHouse({
    required this.id,
    this.ownerId = 0,
    this.name = '',
    this.address = '',
    this.imageUrl = '',
    this.imageUrls = const [],
    this.defaultRoomPrice = 0,
  });

  factory BoardingHouse.fromJson(Map<String, dynamic> json) {
    return BoardingHouse(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      defaultRoomPrice: (json['default_room_price'] ?? 0).toDouble(),
    );
  }
}
