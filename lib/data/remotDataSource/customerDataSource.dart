import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerRemoteDataSource {
  final SupabaseClient supabaseClient; // Supabase Client
  final FirebaseAuth firebaseAuth;     // Firebase Authentication

  CustomerRemoteDataSource(this.supabaseClient, this.firebaseAuth);

  Future<Map<String, dynamic>?> fetchCustomerDetails(String id) async {
    final response = await supabaseClient
        .from('customer')
        .select('*, users(*)')
        .eq('id', id)
        .maybeSingle();

    print("Fetched customer data: $response"); // Add this for debugging

    if (response == null) {
      throw Exception('No customer details found for ID: $id');
    }

    return response as Map<String, dynamic>?;
  }

  /// Validate user from FirebaseAuth
  Future<String> getFirebaseUserId() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user in FirebaseAuth.');
    }
    return user.uid; // Return authenticated user's UID
  }
  /// Save craftsman details
  Future<void> saveCustomerDetails({
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
    await supabaseClient.from('users').upsert({
      'id': uid,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': 'customer',
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(), // Save DOB
    });

    // Insert craftsman data into `craftsman` table
    await supabaseClient.from('customer').upsert({
      'id': uid,
    });

    print('Craftsman details saved successfully.');
  }
}
