import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/remotDataSource/customerDataSource.dart';
import 'package:herafi/domain/entites/customer.dart';
import 'package:herafi/domain/repositories/customerRepository.dart';


class CustomerRepositoryImp extends CustomerRepository {
  final customerRemotDataSource dataSource;

  CustomerRepositoryImp(this.dataSource);

  @override
  Future<Either<Failure, void>> insertCustomer(CustomerEntity customer) async {
    try {
      await dataSource.insertCustomerData(
        firstName: customer.firstName,
        lastName: customer.lastName,
        phoneNumber: customer.phoneNumber,
        dateOfBirth: customer.dateOfBirth,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
