import 'package:herafi/domain/entites/availability.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    super.id, // اجعل id اختيارياً
    required super.craftsmanId,
    required super.availabilityType,
    super.dayOfWeek,
    required super.available,
    super.unavailabilityReason,
  });

  /// إنشاء نموذج من JSON
  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int?, // قد يكون id null
      craftsmanId: json['craftsman_id'] as String,
      availabilityType: json['availability_type'] as String,
      dayOfWeek: json['day_of_week'] as String?,
      available: json['available'] as bool,
      unavailabilityReason: json['unavailability_reason'] as String?,
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // إرسال id فقط إذا كان غير null
      'craftsman_id': craftsmanId,
      'availability_type': availabilityType,
      'day_of_week': dayOfWeek,
      'available': available,
      'unavailability_reason': unavailabilityReason,
    };
  }
}