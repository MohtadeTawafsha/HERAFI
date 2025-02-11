import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/core/status/success/success.dart';
import 'package:herafi/data/models/ProjectModel.dart'; // استخدم ProjectModel
import 'package:herafi/domain/entites/ProjectEntity.dart';
import 'package:herafi/domain/entites/ProjectStepEntity.dart';
import 'package:herafi/global/project_states.dart';
import '../../domain/repositories/ProjectRepository.dart';
import '../remotDataSource/ProjectRemoteDataSource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource=ProjectRemoteDataSource();

  ProjectRepositoryImpl();

  @override
  Future<Either<Failure, success>> insertProject(ProjectEntity project) async {
    try {
      await remoteDataSource.insertProject(project: project);
      return const Right(DatabaseAddingSuccessfully(''));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() async {
    try {
      final result = await remoteDataSource.fetchProjects();
      return Right(result.map((item){
        return ProjectModel.fromJson(item);
      }).toList());
    } catch (e) {
      print(e.toString());
      return Left(ServerFailure('')); // Handle failures appropriately
    }
  }

  @override
  Future<Either<Failure,success>> updateProject(ProjectEntity project) async {
    try {

      // Call remoteDataSource to perform the update
      await remoteDataSource.updateProject( product: project);

      return Right(DatabaseAddingSuccessfully(''));
    } catch (e) {
      return Left(DatabaseFailure(''));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int projectId) async {
    try {
      await remoteDataSource.deleteProject(projectId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> fetchProjectById(int projectId) async {
    try {
      final data = await remoteDataSource.fetchProjectDetails(projectId);
      if (data == null) return Left(ServerFailure("Project not found"));

      // استخدم ProjectModel لتحليل البيانات من JSON
      final project = ProjectModel.fromJson(data);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> fetchAllProjects() async {
    try {
      final data = await remoteDataSource.fetchAllProjects();

      // استخدم ProjectModel لتحليل القائمة
      final projects =
      data.map((json) => ProjectModel.fromJson(json)).toList();
      return Right(projects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    try {
      final response = await remoteDataSource.fetchUserDetails(userId);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  @override
  Future<void> updateProjectState(int projectId, String newState) async {
    try {
      // تحقق من أن الحالة المختارة صحيحة
      if (!projectStates.contains(newState)) {
        throw Exception('الحالة المختارة غير صحيحة');
      }

      // تحديث الحالة في قاعدة البيانات
      await remoteDataSource.updateProjectState(projectId, newState);
    } catch (error) {
      throw Exception('فشل في تحديث الحالة: $error');
    }
  }

  @override
  Future<List<ProjectStepEntity>> fetchProjectSteps(int projectId) async {
    try {
      // Fetch data from the remote data source
      final List<dynamic> data = await remoteDataSource.fetchProjectSteps(projectId);

      // Parse the data into ProjectStepEntity objects
      final steps = data.map((dynamic json) {
        // Ensure the JSON is properly typed
        final Map<String, dynamic> step = json as Map<String, dynamic>;
        return ProjectStepEntity(
          stepNumber: step['step_number'] as int, // Ensure it's cast to int
          title: step['title'] as String, // Ensure it's cast to String
          price: (step['price'] as num).toDouble(), // Convert price to double safely
          duration: step['duration'] as String, // Cast duration to String
          isPaid: step['is_paid'] as bool, // Cast isPaid to bool
        );
      }).toList();

      return steps;
    } catch (e) {
      // Catch and rethrow an exception with a meaningful error message
      throw Exception('Failed to fetch project steps: $e');
    }
  }
  Future<ProjectEntity?> fetchProjectByCustomerAndCraftsman(
      String customerId, String craftsmanId) async {
    print('Fetching project with customerId: $customerId and craftsmanId: $craftsmanId');

    final response = await remoteDataSource.fetchProjectByCustomerAndCraftsmann(
      customerId,
      craftsmanId,
    );

    if (response == null) {
      print('No project found for the specified customer and craftsman.');
      return null; // No project found
    }

    print('Project found: ${response.toString()}');
    return ProjectModel.fromJson(response); // Convert response to entity
  }

  @override
  Future<void> ensureProjectExists(String customerId, String craftsmanId) {
    // TODO: implement ensureProjectExists
    throw UnimplementedError();
  }


}
