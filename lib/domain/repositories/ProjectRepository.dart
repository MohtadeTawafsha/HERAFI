import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';

import '../entites/ProjectEntity.dart';

abstract class ProjectRepository {
  /// Insert a new project
  Future<Either<Failure, void>> insertProject(ProjectEntity project);

  /// Update an existing project
  Future<Either<Failure, void>> updateProject(ProjectEntity project);

  /// Delete a project by ID
  Future<Either<Failure, void>> deleteProject(int projectId);

  /// Fetch project by ID
  Future<Either<Failure, ProjectEntity>> fetchProjectById(int projectId);

  /// Fetch all projects
  Future<Either<Failure, List<ProjectEntity>>> fetchAllProjects();
}
