import 'package:dartz/dartz.dart';

import '../../../core/status/error/Failure.dart';
import '../../entites/job.dart';
import '../../repositories/jobRepository.dart';
class FetchJobsUseCase {
  final JobRepository repository;

  FetchJobsUseCase(this.repository);

  Future<Either<Failure, List<JobEntity>>> call(int page,String category) async {
    return repository.fetchJobs(page,category);
  }
}
