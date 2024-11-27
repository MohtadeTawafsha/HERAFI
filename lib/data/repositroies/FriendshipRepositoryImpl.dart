import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/models/FriendshipModel.dart';
import 'package:herafi/data/remotDataSource/FriendshipRemoteDataSource.dart';
import 'package:herafi/domain/entites/Friendship.dart';
import 'package:herafi/domain/repositories/FriendshipRepository.dart';


class FriendshipRepositoryImpl extends FriendshipRepository {
  final FriendshipRemoteDataSource remoteDataSource;

  FriendshipRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> addFriendship(FriendshipEntity friendship) async {
    try {
      final friendshipModel = FriendshipModel(
        id: friendship.id,
        craftsmanId: friendship.craftsmanId,
        customerId: friendship.customerId,
        status: friendship.status,
        createdAt: friendship.createdAt,
      );
      await remoteDataSource.addFriendship(friendshipModel);
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriendship({
    required String craftsmanId,
    required String customerId,
  }) async {
    try {
      await remoteDataSource.removeFriendship(craftsmanId, customerId);
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowing({
    required String craftsmanId,
    required String customerId,
  }) async {
    try {
      final result =
      await remoteDataSource.isFollowing(craftsmanId, customerId);
      return Right(result);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendshipEntity>>> fetchFollowers(
      String craftsmanId) async {
    try {
      final followers = await remoteDataSource.fetchFollowers(craftsmanId);
      return Right(followers);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendshipEntity>>> fetchFollowedCraftsmen(
      String customerId) async {
    try {
      final followedCraftsmen =
      await remoteDataSource.fetchFollowedCraftsmen(customerId);
      return Right(followedCraftsmen);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}