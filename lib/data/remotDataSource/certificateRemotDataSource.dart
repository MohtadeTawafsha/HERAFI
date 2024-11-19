import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/data/models/certificateModel.dart';
import 'package:herafi/domain/entites/certificate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CertificateRemoteDataSource {
  final SupabaseClient client;
  final FirebaseAuth firebaseAuth;

  CertificateRemoteDataSource(this.client, this.firebaseAuth);

  /// Insert a new certificate for the authenticated craftsman
  Future<void> insertCertificate(CertificateEntity certificate) async {
    // Fetch UID from FirebaseAuth
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase.');
    }

    // Ensure the user is a craftsman
    final craftsmanRecord = await client
        .from('craftsman')
        .select('id')
        .eq('id', user.uid)
        .maybeSingle();

    if (craftsmanRecord == null) {
      throw Exception('No craftsman record found for the current user.');
    }

    // Insert certificate into the `certificate` table
    final result = await client.from('certificate').insert({
      'image': certificate.image,
      'craftsman_id': user.uid,
    }).maybeSingle();

    if (result == null) {
      throw Exception('Failed to insert certificate.');
    }

    print('Certificate inserted successfully.');
  }

  /// Fetch certificates for a specific craftsman
  Future<List<CertificateModel>> fetchCertificates(String craftsmanId) async {
    final result = await client
        .from('certificate')
        .select('*')
        .eq('craftsman_id', craftsmanId);

    if (result == null || result.isEmpty) {
      throw Exception('No certificates found for craftsman ID: $craftsmanId');
    }

    return (result as List)
        .map((data) => CertificateModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Delete a certificate by its ID
  Future<void> deleteCertificate(int certificateId) async {
    final result = await client
        .from('certificate')
        .delete()
        .eq('id', certificateId);

    if (result == null) {
      throw Exception('Failed to delete certificate with ID: $certificateId');
    }

    print('Certificate deleted successfully.');
  }
}
