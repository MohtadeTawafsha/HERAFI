import 'package:herafi/domain/entites/ProjectStepEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProjectRemoteDataSource(this.supabaseClient);

  /// Fetch project details by ID
  Future<Map<String, dynamic>?> fetchProjectDetails(int projectId) async {
    final response = await supabaseClient
        .from('projects')
        .select('*')
        .eq('id', projectId)
        .maybeSingle();

    return response;
  }

  /// Insert a new project
  Future<void> insertProject({
    required String customerId,
    required String craftsmanId,
    required String title,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    String state = 'تم الإرسال للعميل',
  }) async {
    await supabaseClient.from('projects').insert({
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'title': title,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'state': state,
    });
  }

  /// Update project details
  Future<void> updateProject({
    required int projectId,
    required String title,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    String state = 'تم الإرسال للعميل',
  }) async {
    await supabaseClient.from('projects').update({
      'title': title,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'state': state,
    }).eq('id', projectId);
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

  Future<void> insertProjectStep({
    required int projectId,
    required int stepNumber,
    required String title,
    required double price,
    required String duration,
  }) async {
    try {
      await supabaseClient.from('project_steps').insert({
        'project_id': projectId, // يجب أن يكون هذا المعرف صالحًا
        'step_number': stepNumber,
        'title': title,
        'price': price,
        'duration': duration,
        'is_paid': false, // القيمة الافتراضية
      });
    } catch (error) {
      throw Exception('Failed to insert project step: $error');
    }
  }



  Future<Map<String, dynamic>?> fetchProjectByCustomerAndCraftsmann(
      String customerId, String craftsmanId) async {
    final response = await supabaseClient
        .from('projects')
        .select('*')
        .eq('customer_id', customerId)
        .eq('craftsman_id', craftsmanId)
        .maybeSingle();

    return response;
  }

}
