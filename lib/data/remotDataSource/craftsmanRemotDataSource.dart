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
        .select('*, users(*)') // Join craftsman with user data
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      throw Exception('No craftsman details found for ID: $id');
    }

    final Map<String, dynamic> combinedData = {
      'id': response['id'],
      'category': response['category'],
      'years_of_experience': response['years_of_experience'],
      ...response['users'], // Include user data (latitude, longitude, etc.)
    };

    return combinedData;
  }

  /// Save craftsman details
  Future<void> saveCraftsmanDetails({
    required String category,
    required int yearsOfExperience,
    required String name,
    required String location,
    required String phoneNumber,
    required DateTime dateOfBirth,
    String? mapLatitude, // Store latitude in users table
    String? mapLongitude, // Store longitude in users table
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase');
    }
    final String uid = user.uid;

    // Update user details in users table
    await client.from('users').upsert({
      'id': uid,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': 'craftsman',
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'map_latitude': mapLatitude,
      'map_longitude': mapLongitude,
    });

    // Insert craftsman details in craftsman table
    await client.from('craftsman').upsert({
      'id': uid,
      'category': category,
      'years_of_experience': yearsOfExperience,
    });
  }

  /// Update craftsman details
  Future<void> updateCraftsmanDetails({
    required String id,
    required String name,
    required String location,
    required DateTime dateOfBirth,
    required int yearsOfExperience,
    required String category,
    required String image,
    String? mapLatitude, // دعم خطوط الطول
    String? mapLongitude, // دعم خطوط العرض
  }) async {
    await client.from('users').update({
      'name': name,
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'image': image,
      if (mapLatitude != null) 'map_latitude': mapLatitude, // تحديث خط العرض
      if (mapLongitude != null) 'map_longitude': mapLongitude, // تحديث خط الطول
    }).eq('id', id);

    await client.from('craftsman').update({
      'years_of_experience': yearsOfExperience,
      'category': category,
    }).eq('id', id);
  }

}