import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/success/success.dart';
import 'package:herafi/data/models/jobModel.dart';
import '../../core/status/error/Failure.dart';
import '../../domain/entites/job.dart';
import '../../domain/repositories/jobRepository.dart';
import '../remotDataSource/jobRemotDataSource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource=JobRemoteDataSource();


  @override
  Future<Either<Failure, JobEntity>> getJobDetails(int id) async {
    try {
      final job = await remoteDataSource.getJobDetails(id);
      return Right(job);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure,success>> createJob(JobEntity job)async{
    try{
      await remoteDataSource.createJob(job.toModel());
        return Right(DatabaseDeleteSuccessfully('sucess'));
    }
    catch(e){
      return Left(DatabaseFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, List<JobEntity>>> fetchJobs(int page,String category) async {
    try {
      final jobs = await remoteDataSource.fetchJobs(page,category);
      return Right(jobs);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, List<JobEntity>>> searchJobs(String query, int page,String category) async {
    try {
      final jobs = await remoteDataSource.searchJobs(query, page,category);
      return Right(jobs);
    } catch (e) {
      return Left(DatabaseFailure('Error searching for jobs'));
    }
  }

  Future<Either<Failure, List<JobEntity>>> fetchCustomerForCustomer(String customerId) async {
    try {
      final jobs = await remoteDataSource.fetchJobForCustomer(customerId);
      return Right(jobs);
    } catch (e) {
      return Left(DatabaseFailure('Error searching for jobs'));
    }
  }
}
