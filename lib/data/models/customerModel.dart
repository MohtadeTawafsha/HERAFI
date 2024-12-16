import 'package:herafi/domain/entites/craftsman.dart';
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
    required super.dateOfBirth, // Include DOB
  });

  /// Convert JSON to CraftsmanModel
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'],
      id: json['id'],
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
      location: json['location']??"",
      dateOfBirth: DateTime.parse(json['date_of_birth']), // Parse DOB
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
