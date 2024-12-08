import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/availability.dart';

abstract class AvailabilityRepository {
  // Fetch all availability records for a specific craftsman
  Future<Either<Failure, List<AvailabilityEntity>>> fetchAvailability(String craftsmanId);

  // Add a new availability record
  Future<Either<Failure, void>> addAvailability(AvailabilityEntity availability);

  // Update an existing availability record
  Future<Either<Failure, void>> updateAvailability(AvailabilityEntity availability);
}
