class AvailabilityEntity {
  final int id;
  final String craftsmanId;
  final String availabilityType; // 'simple' or 'schedule'
  final String? dayOfWeek; // Nullable, only relevant for 'schedule'
  final bool available;
  final String? unavailabilityReason; // Nullable, reason for unavailability
  final bool receiveOffersOffline; // Whether the craftsman can receive offers offline

  AvailabilityEntity({
    required this.id,
    required this.craftsmanId,
    required this.availabilityType,
    this.dayOfWeek, // Nullable
    required this.available,
    this.unavailabilityReason, // Nullable
    required this.receiveOffersOffline,
  });
}
