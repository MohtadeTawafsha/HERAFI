import 'package:supabase_flutter/supabase_flutter.dart';

class CraftsmanRemoteDataSource {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> insertCraftsmanData({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required int yearsOfExperience,
    required String category,
  }) async {
    final response = await supabaseClient.from('craftsman').insert({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'yearsOfExperience': yearsOfExperience,
      'category': category,
    });

    if (response.error != null) {
      throw Exception("Failed to insert craftsman data: ${response.error!.message}");
    }
  }
}
