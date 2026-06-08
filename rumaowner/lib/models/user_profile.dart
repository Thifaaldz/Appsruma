class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.profileImage,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String gender;
  final String birthDate;
  final String address;
  final String profileImage;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? gender,
    String? birthDate,
    String? address,
    String? profileImage,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
