class BoardingHouse {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String imageUrl;
  final int totalRooms;
  final int vacantRooms;

  BoardingHouse({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.totalRooms = 0,
    this.vacantRooms = 0,
  });

  factory BoardingHouse.fromJson(Map<String, dynamic> json) {
    final rooms = json['rooms'] as List? ?? [];
    final vacant = rooms.where((r) => r['status'] == 'available').length;
    return BoardingHouse(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      totalRooms: rooms.length,
      vacantRooms: vacant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'image_url': imageUrl,
    };
  }
}
