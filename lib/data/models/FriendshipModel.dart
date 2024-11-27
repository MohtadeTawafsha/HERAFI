import 'package:herafi/domain/entites/Friendship.dart';

class FriendshipModel extends FriendshipEntity {
  const FriendshipModel({
    required super.id,
    required super.craftsmanId,
    required super.customerId,
    required super.createdAt,
    super.status,
  });

  /// Convert JSON to FriendshipModel
  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'],
      craftsmanId: json['craftsman_id'],
      customerId: json['customer_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert FriendshipModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'craftsman_id': craftsmanId,
      'customer_id': customerId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
