class FriendshipEntity {
  final int id;
  final String craftsmanId;
  final String customerId;
  final int? status; // Nullable
  final DateTime createdAt;

  const FriendshipEntity({
    required this.id,
    required this.craftsmanId,
    required this.customerId,
    this.status, // Status can be null
    required this.createdAt,
  });
}