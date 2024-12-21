import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRemoteDataSource {
  final SupabaseClient supabaseClient;
  final FirebaseAuth firebaseAuth;

  ProjectRemoteDataSource(this.supabaseClient, this.firebaseAuth);

  /// Fetch project details by ID
  Future<Map<String, dynamic>?> fetchProjectDetails(int projectId) async {
    final response = await supabaseClient
        .from('projects')
        .select('*')
        .eq('id', projectId)
        .maybeSingle();

    if (response == null) {
      throw Exception('No project details found for ID: $projectId');
    }

    return response;
  }

  /// Insert a new project
  Future<void> saveProjectDetails({
    required String title,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? craftsmanId,
    String state = 'تم الإرسال للعميل',
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase');
    }

    await supabaseClient.from('projects').insert({
      'title': title,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'state': state,
    });
  }

  /// Update project details
  Future<void> updateProjectDetails({
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
    if (response == null) {
      throw Exception('Error fetching projects');
    }

    return response as List<Map<String, dynamic>>;
  }
}
