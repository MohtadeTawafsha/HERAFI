import 'package:supabase_flutter/supabase_flutter.dart';

class customerRemotDataSource {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> insertCustomerData({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) async {
    final response = await supabaseClient.from('customer').insert({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    });

    if (response.error != null) {
      throw Exception("Failed to insert customer data: ${response.error!.message}");
    }
  }
}
