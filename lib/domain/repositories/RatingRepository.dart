import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';

import '../entites/RatingEntity.dart';

abstract class RatingRepository {
  Future<Either<Failure, String>> addRating(RatingEntity rating);
  Future<Either<Failure, List<RatingEntity>>> fetchRatingsByCraftsman(String craftsmanId);
}