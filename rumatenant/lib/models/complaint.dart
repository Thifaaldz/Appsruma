class Complaint {
  final int id;
  final int tenantId;
  final String title;
  final String description;
  final String status;

  Complaint({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      tenantId: json['tenant_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
