class Announcement {
  final int id;
  final int ownerId;
  final int boardingHouseId;
  final String targetType;
  final int? targetUserId;
  final String? targetUserName;
  final String title;
  final String content;
  final DateTime date;
  final String icon;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.ownerId,
    required this.boardingHouseId,
    this.targetType = 'boarding_house',
    this.targetUserId,
    this.targetUserName,
    required this.title,
    required this.content,
    required this.date,
    this.icon = 'info',
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      boardingHouseId: json['boarding_house_id'] ?? 0,
      targetType: json['target_type'] ?? 'boarding_house',
      targetUserId: json['target_user_id'],
      targetUserName: json['target_user']?['name'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      icon: json['icon'] ?? 'info',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'boarding_house_id': boardingHouseId,
      'target_type': targetType,
      if (targetUserId != null) 'target_user_id': targetUserId,
      'content': content,
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'icon': icon,
    };
  }
}
