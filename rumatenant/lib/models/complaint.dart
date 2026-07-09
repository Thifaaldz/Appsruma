class Complaint {
  final int id;
  final int tenantId;
  final String title;
  final String description;
  final String photoUrl;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.id,
    this.tenantId = 0,
    required this.title,
    required this.description,
    this.photoUrl = '',
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'photo_url': photoUrl};
  }
}
