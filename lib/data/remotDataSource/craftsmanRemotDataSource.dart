import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CraftsmanRemoteDataSource {
  final SupabaseClient client;
  final FirebaseAuth firebaseAuth;

  CraftsmanRemoteDataSource(this.client, this.firebaseAuth);

  /// Fetch craftsman details by ID
  Future<Map<String, dynamic>?> fetchCraftsmanDetails(String id) async {
    final response = await client
        .from('craftsman')
        .select('*, users(*)') // Fetch associated user data from 'users' table
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      throw Exception('No craftsman details found for ID: $id');
    }

    return response as Map<String, dynamic>?;
  }

  /// Save craftsman details
  Future<void> saveCraftsmanDetails({
    required String category,
    required int yearsOfExperience,
    required String name,
    required String location,
    required String phoneNumber,
    required DateTime dateOfBirth, // Include DOB
  }) async {
    // Fetch UID from FirebaseAuth
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase');
    }
    final String uid = user.uid;

    // Insert user data into `users` table
    await client.from('users').upsert({
      'id': uid,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': 'craftsman',
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(), // Save DOB
    });

    // Insert craftsman data into `craftsman` table
    await client.from('craftsman').upsert({
      'id': uid,
      'category': category,
      'years_of_experience': yearsOfExperience,
    });

    print('Craftsman details saved successfully.');
  }
}
