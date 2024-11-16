import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:herafi/domain/entites/customer.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    required super.id,
    required super.createdAt,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.dateOfBirth,
  });
  // Convert JSON to Model
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
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
    };
  }

  Future<void> insertCustomer({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) async {
    final response = await Supabase.instance.client.from('customer').insert({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    });

    if (response.error != null) {
      throw Exception("Failed to insert customer: ${response.error!.message}");
    }
  }
}
