import 'package:dartz/dartz.dart';
import '../../core/status/error/Failure.dart';
import '../../core/status/success/success.dart';
import '../entites/job.dart';

abstract class JobRepository {
  Future<Either<Failure, JobEntity>> getJobDetails(int id);
  Future<Either<Failure,success>> createJob(JobEntity job);
  Future<Either<Failure, List<JobEntity>>> fetchJobs(int page,String category);
  Future<Either<Failure, List<JobEntity>>> searchJobs(String query, int page,String category);
}
