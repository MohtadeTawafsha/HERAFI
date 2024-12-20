import 'package:herafi/domain/entites/customer.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    required super.name,
    required super.id,
    required super.image,
    required super.createdAt,
    required super.phoneNumber,
    required super.userType,
    required super.location,
    required super.dateOfBirth,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final userData = json['users'] ?? {};
    return CustomerModel(
      name: userData['name'] ?? "No Name",
      id: json['id'] ?? "",
      image: userData['image'] ?? "",
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : DateTime.now(),
      phoneNumber: userData['phone_number'] ?? "N/A",
      userType: userData['user_type'] ?? "customer",
      location: userData['location'] ?? "Unknown",
      dateOfBirth: userData['date_of_birth'] != null
          ? DateTime.parse(userData['date_of_birth'])
          : DateTime.now(),
    );
  }

  /// Convert CraftsmanModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'phone_number': phoneNumber,
      'user_type': userType,
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(), // Save DOB
    };
  }
}
