class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String gender;
  final String birthDate;
  final String address;
  final String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = '',
    this.phone = '',
    this.gender = '',
    this.birthDate = '',
    this.address = '',
    this.profileImage = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'address': address,
      'profile_image': profileImage,
    };
  }
}
