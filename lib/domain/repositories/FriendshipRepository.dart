import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/Friendship.dart';

abstract class FriendshipRepository {
  /// Add a new friendship (follow action)
  Future<Either<Failure, void>> addFriendship(FriendshipEntity friendship);

  /// Remove a friendship (unfollow action)
  Future<Either<Failure, void>> removeFriendship({
    required String craftsmanId,
    required String customerId,
  });

  /// Check if a customer follows a craftsman
  Future<Either<Failure, bool>> isFollowing({
    required String craftsmanId,
    required String customerId,
  });

  /// Get all customers following a specific craftsman
  Future<Either<Failure, List<FriendshipEntity>>> fetchFollowers(String craftsmanId);

  /// Get all craftsmen followed by a specific customer
  Future<Either<Failure, List<FriendshipEntity>>> fetchFollowedCraftsmen(String customerId);
}
