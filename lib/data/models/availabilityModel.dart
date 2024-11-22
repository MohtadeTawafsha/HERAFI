import 'package:herafi/domain/entites/availability.dart';

class AvailabilityModel extends AvailabilityEntity {
  AvailabilityModel({
    required super.id,
    required super.craftsmanId,
    required super.availabilityType,
    super.dayOfWeek, // Nullable
    required super.available,
    super.unavailabilityReason, // Nullable
    required super.receiveOffersOffline,
  });

  // Factory method to create a model from Supabase JSON data
  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id']),
      craftsmanId: json['craftsman_id'] as String,
      availabilityType: json['availability_type'] as String,
      dayOfWeek: json['day_of_week'] as String?, // Nullable
      available: json['available'] as bool,
      unavailabilityReason: json['unavailability_reason'] as String?, // Nullable
      receiveOffersOffline: json['receive_offers_offline'] as bool,
    );
  }

  // Method to convert the model to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'craftsman_id': craftsmanId,
      'availability_type': availabilityType,
      'day_of_week': dayOfWeek,
      'available': available,
      'unavailability_reason': unavailabilityReason,
      'receive_offers_offline': receiveOffersOffline,
    };
  }
}
