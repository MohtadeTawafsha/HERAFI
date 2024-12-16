import 'package:dartz/dartz.dart';

import '../../../core/status/error/Failure.dart';
import '../../entites/job.dart';
import '../../repositories/jobRepository.dart';
class SearchJobsUseCase {
  final JobRepository repository;

  SearchJobsUseCase(this.repository);

  Future<Either<Failure, List<JobEntity>>> call(String query, int page,String category) async {
    return repository.searchJobs(query, page,category);
  }
}
