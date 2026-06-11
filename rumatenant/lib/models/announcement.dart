class Announcement {
  final int id;
  final int ownerId;
  final String title;
  final String content;
  final DateTime date;
  final String icon;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.ownerId,
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
}
