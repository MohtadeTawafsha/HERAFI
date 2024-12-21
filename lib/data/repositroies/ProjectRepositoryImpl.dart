import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/models/projectModel.dart';
import 'package:herafi/data/remotDataSource/projectRemoteDataSource.dart';
import 'package:herafi/domain/repositories/projectRepository.dart';

import '../../domain/entites/ProjectEntity.dart';

class ProjectRepositoryImpl extends ProjectRepository {
  final ProjectRemoteDataSource dataSource;

  ProjectRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> insertProject(ProjectEntity project) async {
    try {
      await dataSource.saveProjectDetails(
        title: project.title,
        price: project.price ?? 0.0, // استخدام قيمة افتراضية إذا كانت null
        startDate: project.startDate ?? DateTime.now(),
        endDate: project.endDate ?? DateTime.now(),
        customerId: project.customerId ?? 'Unknown', // قيمة افتراضية
        craftsmanId: project.craftsmanId?? 'Unknown',
        state: project.state,
      );
      return const Right(null);
    } catch (error, stacktrace) {
      // تسجيل التفاصيل لمزيد من التشخيص
      print('Error in insertProject: $error');
      print(stacktrace);
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProject(ProjectEntity project) async {
    try {
      await dataSource.updateProjectDetails(
        projectId: project.id,
        title: project.title,
        price: project.price ?? 0.0,
        startDate: project.startDate ?? DateTime.now(),
        endDate: project.endDate ?? DateTime.now(),
        state: project.state,
      );
      return const Right(null);
    } catch (error, stacktrace) {
      print('Error in updateProject: $error');
      print(stacktrace);
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int projectId) async {
    try {
      await dataSource.deleteProject(projectId);
      return const Right(null);
    } catch (error, stacktrace) {
      print('Error in deleteProject: $error');
      print(stacktrace);
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> fetchProjectById(int projectId) async {
    try {
      final data = await dataSource.fetchProjectDetails(projectId);

      if (data == null) {
        return Left(ServerFailure("Project not found"));
      }

      try {
        final projectModel = ProjectModel.fromJson(data);
        return Right(projectModel);
      } catch (e) {
        // إذا كان هناك مشكلة في التحويل إلى النموذج
        return Left(ServerFailure("Error parsing project data: ${e.toString()}"));
      }
    } catch (error, stacktrace) {
      print('Error in fetchProjectById: $error');
      print(stacktrace);
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> fetchAllProjects() async {
    try {
      final data = await dataSource.fetchAllProjects();

      // التحقق من استجابة البيانات
      if (data.isEmpty) {
        return const Right([]); // إعادة قائمة فارغة إذا لم يتم العثور على مشاريع
      }

      try {
        final projectList =
        data.map((project) => ProjectModel.fromJson(project)).toList();
        return Right(projectList);
      } catch (e) {
        // إذا كان هناك مشكلة في التحويل إلى النموذج
        return Left(ServerFailure("Error parsing project list: ${e.toString()}"));
      }
    } catch (error, stacktrace) {
      print('Error in fetchAllProjects: $error');
      print(stacktrace);
      return Left(ServerFailure(error.toString()));
    }
  }
}
