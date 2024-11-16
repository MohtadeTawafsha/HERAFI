import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, void>> insertCustomer(CustomerEntity customer);
}
