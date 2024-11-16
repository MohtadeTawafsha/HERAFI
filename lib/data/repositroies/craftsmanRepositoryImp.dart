import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/remotDataSource/craftsmanRemotDataSource.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/domain/repositories/craftsmanRepository.dart';

class CraftsmanRepositoryImpl extends CraftsmanRepository {
  final CraftsmanRemoteDataSource dataSource;

  CraftsmanRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> insertCraftsman(CraftsmanEntity craftsman) async {
    try {
      await dataSource.insertCraftsmanData(
        firstName: craftsman.firstName,
        lastName: craftsman.lastName,
        phoneNumber: craftsman.phoneNumber,
        dateOfBirth: craftsman.dateOfBirth,
        yearsOfExperience: craftsman.yearsOfExperience,
        category: craftsman.category,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
