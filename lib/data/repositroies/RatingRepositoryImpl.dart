import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import '../../data/remotDataSource/ratingRemoteDataSource.dart';
import '../../domain/entites/RatingEntity.dart';
import '../../domain/repositories/RatingRepository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> addRating(RatingEntity rating) async {
    try {
      await remoteDataSource.addRating(rating.toModel()); // تحويل RatingEntity إلى RatingModel
      return Right('Rating added successfully');
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> fetchRatingsByCraftsman(String craftsmanId) async {
    try {
      final ratings = await remoteDataSource.fetchRatingsByCraftsman(craftsmanId);
      return Right(ratings.cast<RatingEntity>());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}