import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/ProjectEntity.dart';
import 'package:herafi/domain/entites/ProjectStepEntity.dart';

import '../../core/status/success/success.dart';

abstract class ProjectRepository {
  Future<Either<Failure,success>> insertProject(ProjectEntity project);
  Future<Either<Failure, List<ProjectEntity>>> getProjects();
  Future<Either<Failure, void>> deleteProject(int projectId);
  Future<Either<Failure, ProjectEntity>> fetchProjectById(int projectId);
  Future<Either<Failure, List<ProjectEntity>>> fetchAllProjects();
  Future<void> ensureProjectExists(String customerId, String craftsmanId);
  Future<Map<String, dynamic>> fetchUserDetails(String userId);
  Future<void> updateProjectState(int projectId, String newState);
  Future<List<ProjectStepEntity>> fetchProjectSteps(int projectId);
  Future<Either<Failure,success>> updateProject(ProjectEntity project);
  Future<ProjectEntity?> fetchProjectByCustomerAndCraftsman(
      String customerId, String craftsmanId);

}
