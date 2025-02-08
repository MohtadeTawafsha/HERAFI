import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/domain/entites/certificate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class CertificateRemoteDataSource {
  final SupabaseClient client;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  CertificateRemoteDataSource(this.client, this.firebaseAuth, this.firebaseStorage);

  /// Upload an image to Firebase Storage and return its URL
  Future<String> _uploadImageToFirebase(File image) async {
    try {
      final fileName = 'certificates/${DateTime.now().millisecondsSinceEpoch}';
      final ref = firebaseStorage.ref().child(fileName);
       await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  /// Insert a new certificate with an image uploaded to Firebase Storage
  Future<void> insertCertificateWithImage(CertificateEntity certificate, File image) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase.');
    }

    // Upload image to Firebase Storage
    final imageUrl = await _uploadImageToFirebase(image);

    // Insert the certificate record into the `certificate` table
    await client.from('certificate').insert({
      'image': imageUrl,
      'craftsman_id': user.uid,
    });
    print('Certificate with image inserted successfully.');
  }

  /// Fetch all certificates for a specific craftsman
  Future<List<CertificateEntity>> fetchCertificates(String craftsmanId) async {
    final response = await client
        .from('certificate')
        .select('*')
        .eq('craftsman_id', craftsmanId);

    if (response.isEmpty) {
      throw Exception('No certificates found for craftsman ID: $craftsmanId');
    }

    return response.map((data) {
      return CertificateEntity(
        id: data['id'],
        createdAt: DateTime.parse(data['created_at']),
        image: data['image'],
        craftsmanId: data['craftsman_id'],
      );
    }).toList();
  }

  /// Delete a certificate by its ID
  Future<void> deleteCertificate(int certificateId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firebase.');
    }

    // Fetch the certificate to retrieve the image URL
    final certificate = await client
        .from('certificate')
        .select('image')
        .eq('id', certificateId)
        .maybeSingle();

    if (certificate == null) {
      throw Exception('Certificate not found.');
    }

    final imageUrl = certificate['image'];

    // Delete the image from Firebase Storage
    if (imageUrl != null) {
      final ref = firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
    }

    // Delete the certificate record from the database
    await client.from('certificate').delete().eq('id', certificateId);
    print('Certificate deleted successfully.');
  }
}
