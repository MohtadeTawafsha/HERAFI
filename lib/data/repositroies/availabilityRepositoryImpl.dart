import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/remotDataSource/availabilityRemoteDataSource.dart';
import 'package:herafi/domain/entites/availability.dart';
import 'package:herafi/domain/repositories/availabilityRepository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityRemoteDataSource remoteDataSource;

  AvailabilityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AvailabilityEntity>>> fetchAvailability(String craftsmanId) async {
    try {
      final availabilityList = await remoteDataSource.fetchAvailability(craftsmanId);
      return Right(availabilityList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAvailability(AvailabilityEntity availability) async {
    try {
      await remoteDataSource.addAvailability(availability);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAvailability(AvailabilityEntity availability) async {
    try {
      await remoteDataSource.updateAvailability(availability);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
