
import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/core/status/success/success.dart';
import 'package:herafi/domain/entites/job.dart';
import 'package:herafi/domain/repositories/jobRepository.dart';

class createJobUseCase {
  final JobRepository repository;

  createJobUseCase(this.repository);

  Future<Either<Failure,success>> call(JobEntity job) async {
    return await repository.createJob(job);
  }
}
