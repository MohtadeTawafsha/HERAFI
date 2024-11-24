class AvailabilityEntity {
  final int id;
  final String craftsmanId;
  final String availabilityType;
  final String? dayOfWeek;
  final bool available;
  final String? unavailabilityReason;

  const AvailabilityEntity({
    required this.id,
    required this.craftsmanId,
    required this.availabilityType,
    this.dayOfWeek,
    required this.available,
    this.unavailabilityReason,
  });
}
