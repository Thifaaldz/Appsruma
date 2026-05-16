class Room {
  final int id;
  final int boardingHouseId;
  final String roomNumber;
  final double price;
  final String status;

  Room({
    required this.id,
    required this.boardingHouseId,
    required this.roomNumber,
    required this.price,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      boardingHouseId: json['boarding_house_id'],
      roomNumber: json['room_number'],
      price: json['price'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boarding_house_id': boardingHouseId,
      'room_number': roomNumber,
      'price': price,
      'status': status,
    };
  }
}
