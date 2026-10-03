class UserModel {
  final String id;
  final String email;
  final String username;
  final String? name;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role; // Always "Passanger" for passenger accounts
  final String status;
  final String? stationId;
  final bool emailVerified;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.name,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.stationId,
    this.emailVerified = false,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!;
    }
    return '$firstName $lastName'.trim();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Passanger',
      status: json['status']?.toString() ?? 'active',
      stationId: json['stationId']?.toString(),
      emailVerified: json['emailVerified'] == true,
      image: json['image']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'stationId': stationId,
      'emailVerified': emailVerified,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
