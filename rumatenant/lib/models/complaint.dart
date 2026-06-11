class Complaint {
  final int id;
  final int tenantId;
  final String title;
  final String description;
  final String photoUrl;
  final String status;

  Complaint({
    required this.id,
    this.tenantId = 0,
    required this.title,
    required this.description,
    this.photoUrl = '',
    this.status = 'pending',
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'photo_url': photoUrl};
  }
}
