class AvailabilityEntity {
  final int? id; // اجعل الحقل اختيارياً
  final String craftsmanId;
  final String availabilityType;
  final String? dayOfWeek;
  final bool available;
  final String? unavailabilityReason;

  const AvailabilityEntity({
    this.id, // الحقل اختيارياً
    required this.craftsmanId,
    required this.availabilityType,
    this.dayOfWeek,
    required this.available,
    this.unavailabilityReason,
  });
}