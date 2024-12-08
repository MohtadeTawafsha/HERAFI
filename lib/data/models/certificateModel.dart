import 'package:herafi/domain/entites/certificate.dart';

class CertificateModel extends CertificateEntity {
  CertificateModel({
    required super.id,
    required super.createdAt,
    super.image, // Nullable
    required super.craftsmanId,
  });

  // Factory method to create a model from JSON data (e.g., from Supabase)
  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id']),
      createdAt: DateTime.parse(json['created_at'] as String),
      image: json['image'] as String?, // Nullable
      craftsmanId: json['craftsman_id'] as String,
    );
  }

  // Method to convert the model to JSON (e.g., for inserting/updating in Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'image': image,
      'craftsman_id': craftsmanId,
    };
  }
}
