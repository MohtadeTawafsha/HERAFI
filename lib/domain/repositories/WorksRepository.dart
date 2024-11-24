import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/work.dart';

abstract class WorksRepository {
  Future<Either<Failure, List<WorkEntity>>> fetchWorks(String craftsmanId);
  Future<Either<Failure, void>> insertWork(WorkEntity work);
  Future<Either<Failure, void>> updateWork(WorkEntity work);
Future<Either<Failure, void>> deleteWork(int id);

}
