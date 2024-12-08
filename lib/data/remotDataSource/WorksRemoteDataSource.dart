import 'package:herafi/data/models/WorkModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorksRemoteDataSource {
  final SupabaseClient client;

  WorksRemoteDataSource(this.client);

  /// Fetch works for a given craftsman ID
  Future<List<WorkModel>> fetchWorks(String craftsmanId) async {
    final response = await client
        .from('works')
        .select()
        .eq('craftsman_id', craftsmanId)
        .order('created_at', ascending: false);

    if (response is List) {
      return response.map((work) => WorkModel.fromJson(work)).toList();
    } else {
      throw Exception('Unexpected response format while fetching works');
    }
  }

  /// Insert a new work into the database
  Future<void> insertWork(WorkModel work) async {
    final response = await client.from('works').insert(work.toJson()).select();

    if (response is List) {
      print("Work inserted successfully: $response");
    } else {
      throw Exception('Unexpected response format while inserting work');
    }
  }
  /// Update an existing work
Future<void> updateWork(WorkModel work) async {
  final response = await client
      .from('works')
      .update(work.toJson())
      .eq('id', work.id)
      .select();

  if (response is! List) {
    throw Exception('Unexpected response format while updating work');
  }
}

/// Delete an existing work
Future<void> deleteWork(int id) async {
  final response = await client.from('works').delete().eq('id', id).select();

  if (response is! List) {
    throw Exception('Unexpected response format while deleting work');
  }
}

}
