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
    required DateTime dateOfBirth,
    String? mapLatitude, // تخزين خطوط العرض
    String? mapLongitude, // تخزين خطوط الطول
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase');
    }
    final String uid = user.uid;

    await supabaseClient.from('users').upsert({
      'id': uid,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': 'customer',
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'map_latitude': mapLatitude,
      'map_longitude': mapLongitude,
    });

    await supabaseClient.from('customer').upsert({'id': uid});
  }

  Future<void> updateCustomerDetails({
    required String id,
    required String name,
    required String location,
    required DateTime dateOfBirth,
    String? mapLatitude,
    String? mapLongitude,
    String? image,
  }) async {
    await supabaseClient.from('users').update({
      'name': name,
      'location': location,
      'date_of_birth': dateOfBirth.toIso8601String(),
      if (mapLatitude != null) 'map_latitude': mapLatitude, // تحديث خط العرض
      if (mapLongitude != null) 'map_longitude': mapLongitude, // تحديث خط الطول
      if (image != null) 'image': image, // تحديث الصورة إذا كانت موجودة
    }).eq('id', id);
  }


}
