class Complaint {
  final int id;
  final int tenantId;
  final String title;
  final String description;
  final String photoUrl;
  final String status;
  final String? tenantName;
  final String? roomInfo;

  Complaint({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.description,
    this.photoUrl = '',
    required this.status,
    this.tenantName,
    this.roomInfo,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    String? tenantName;
    String? roomInfo;
    if (json['tenant'] != null) {
      if (json['tenant']['user'] != null) {
        tenantName = json['tenant']['user']['name'];
      }
      if (json['tenant']['room'] != null) {
        roomInfo = 'Kamar ${json['tenant']['room']['room_number']}';
      }
    }
    return Complaint(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      status: json['status'] ?? 'pending',
      tenantName: tenantName,
      roomInfo: roomInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'photo_url': photoUrl,
      'status': status,
    };
  }
}
