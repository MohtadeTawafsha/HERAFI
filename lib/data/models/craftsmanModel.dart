import 'package:herafi/domain/entites/craftsman.dart';

class CraftsmanModel extends CraftsmanEntity {
  CraftsmanModel({
    required super.id,
    required super.createdAt,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.dateOfBirth,
    required super.yearsOfExperience,
    required super.category,
  });

  // Convert JSON to Model
  factory CraftsmanModel.fromJson(Map<String, dynamic> json) {
    return CraftsmanModel(
      id: json['id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      yearsOfExperience: json['yearsOfExperience'] as int,
      category: json['category'],
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'yearsOfExperience': yearsOfExperience,
      'category': category,
    };
  }
}
