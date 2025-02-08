import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/domain/entites/ProjectEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRemoteDataSource {
  final SupabaseClient supabaseClient=Supabase.instance.client;

  ProjectRemoteDataSource();

  /// Fetch project details by ID
  Future<Map<String, dynamic>?> fetchProjectDetails(int projectId) async {
    final response = await supabaseClient
        .from('projects')
        .select('*, ratings(*)')
        .eq('id', projectId)
        .maybeSingle();

    return response;
  }

  /// Insert a new project
  Future<void> insertProject({required ProjectEntity project}) async {
      await supabaseClient.from('projects').insert(project.toModel().toJson());
  }

  Future<List<Map<String,dynamic>>> fetchProjects() async {
    String userId=FirebaseAuth.instance.currentUser!.uid;
    return  await supabaseClient
        .from('projects') // Replace with your actual table name
        .select('*, ratings(*)')
        .or('customer_id.eq.$userId,craftsman_id.eq.$userId');
  }


  /// Update project details
  Future<void> updateProject({required ProjectEntity product}) async {
    await supabaseClient.from('projects').update(product.toModel().toJson()).eq('id', product.id);
  }



  /// Delete a project by ID
  Future<void> deleteProject(int projectId) async {
    await supabaseClient.from('projects').delete().eq('id', projectId);
  }

  /// Fetch all projects
  Future<List<Map<String, dynamic>>> fetchAllProjects() async {
    final response = await supabaseClient.from('projects').select('*');
    return List<Map<String, dynamic>>.from(response);
  }


  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    final response = await supabaseClient
        .from('users')
        .select('name, phone_number, image')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      throw Exception('User not found');
    }

    return response;
  }

  Future<void> updateProjectState(int projectId, String newState) async {
    try {
      await supabaseClient
          .from('projects')
          .update({'state': newState})
          .eq('id', projectId);
    } catch (error) {
      throw Exception('فشل في تحديث الحالة: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProjectSteps(int projectId) async {
    final response = await supabaseClient
        .from('project_steps')
        .select('*')
        .eq('project_id', projectId)
        .order('step_number', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }




  Future<Map<String, dynamic>?> fetchProjectByCustomerAndCraftsmann(
      String customerId, String craftsmanId) async {
    final response = await Supabase.instance.client
        .from('projects')
        .select('*')
        .eq('customer_id', customerId)
        .eq('craftsman_id', craftsmanId)
        .maybeSingle(); // Ensures a single result or null

    return response;
  }

  Future<List<Map<String, dynamic>>> fetchProjectStepsByProjectId(int projectId) async {
    final response = await Supabase.instance.client
        .from('project_steps')
        .select('*') // Fetch all columns
        .eq('project_id', projectId); // New Code: No .execute()

    if (response == null) {
      throw Exception('Error fetching project steps: No data found.');
    }

    return List<Map<String, dynamic>>.from(response);
  }



  Future<void> updateProjectStep(int stepId, Map<String, dynamic> data) async {
    final response = await Supabase.instance.client
        .from('project_steps') // Table name
        .update(data) // Data to update
        .eq('id', stepId) // Match the specific step by ID
        .select();

    if (response == null || response.isEmpty) {
      throw Exception('Error updating project step: No rows were updated.');
    }
  }









}
