import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/models/customerModel.dart';
import 'package:herafi/data/remotDataSource/customerDataSource.dart';
import 'package:herafi/domain/entites/customer.dart';
import 'package:herafi/domain/repositories/customerRepository.dart';

class CustomerRepositoryImpl extends CustomerRepository {
  final CustomerRemoteDataSource dataSource;

  CustomerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> insertCustomer(CustomerEntity customer) async {
    try {
      await dataSource.saveCustomerDetails(
        name: customer.name,
        phoneNumber: customer.phoneNumber,
        dateOfBirth: customer.dateOfBirth,
        location: customer.location,
      );
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> fetchCustomerById(String customerId) async {
    try {
      // Fetch customer details from Supabase
      final data = await dataSource.fetchCustomerDetails(customerId);

      if (data == null) {
        return Left(ServerFailure("Customer not found"));
      }

      final customerModel = CustomerModel.fromJson(data);
      return Right(customerModel);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
  Future<void> updateCustomer(CustomerEntity customer) async {
    await dataSource.updateCustomerDetails(
      id: customer.id,
      name: customer.name,
      location: customer.location, // احتفظ بالموقع الحالي
      dateOfBirth: customer.dateOfBirth,

    );
  }


}