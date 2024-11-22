import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/availability.dart';

abstract class AvailabilityRepository {
  Future<Either<Failure, List<AvailabilityEntity>>> fetchAvailability(String craftsmanId);
  Future<Either<Failure, void>> addAvailability(AvailabilityEntity availability);
  Future<Either<Failure, void>> updateAvailability(AvailabilityEntity availability);
}
