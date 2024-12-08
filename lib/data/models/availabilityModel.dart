import 'package:herafi/domain/entites/availability.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.id,
    required super.craftsmanId,
    required super.availabilityType,
    super.dayOfWeek,
    required super.available,
    super.unavailabilityReason,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int,
      craftsmanId: json['craftsman_id'] as String,
      availabilityType: json['availability_type'] as String,
      dayOfWeek: json['day_of_week'] as String?,
      available: json['available'] as bool,
      unavailabilityReason: json['unavailability_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'craftsman_id': craftsmanId,
      'availability_type': availabilityType,
      'day_of_week': dayOfWeek,
      'available': available,
      'unavailability_reason': unavailabilityReason,
    };
  }
}
