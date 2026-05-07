class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
  });

  bool get isAdmin => role == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        email: json['email'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        phone: json['phone'],
        role: json['role'] ?? 'CLIENT',
      );
}
