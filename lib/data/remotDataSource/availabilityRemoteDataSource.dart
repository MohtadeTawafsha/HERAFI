import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/data/models/availabilityModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:herafi/domain/entites/availability.dart';

class AvailabilityRemoteDataSource {
  final SupabaseClient client;
  final FirebaseAuth firebaseAuth;

  AvailabilityRemoteDataSource(this.client, this.firebaseAuth);

  /// Fetch all availability records for a specific craftsman
  Future<List<AvailabilityEntity>> fetchAvailability(String craftsmanId) async {
    try {
      final response = await client
          .from('availability')
          .select('*')
          .eq('craftsman_id', craftsmanId)
          .then((value) => value as List<dynamic>);

      return response
          .map((json) => AvailabilityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching availability: $e');
    }
  }

  /// Add a new availability record
  Future<void> addAvailability(AvailabilityEntity availability) async {
    try {
      final payload = AvailabilityModel(
        id: availability.id,
        craftsmanId: availability.craftsmanId,
        availabilityType: availability.availabilityType,
        dayOfWeek: availability.dayOfWeek,
        available: availability.available,
        unavailabilityReason: availability.unavailabilityReason,
        receiveOffersOffline: availability.receiveOffersOffline,
      ).toJson();

      await client.from('availability').insert(payload);
    } catch (e) {
      throw Exception('Error adding availability: $e');
    }
  }

  /// Update an existing availability record
  Future<void> updateAvailability(AvailabilityEntity availability) async {
    try {
      final payload = AvailabilityModel(
        id: availability.id,
        craftsmanId: availability.craftsmanId,
        availabilityType: availability.availabilityType,
        dayOfWeek: availability.dayOfWeek,
        available: availability.available,
        unavailabilityReason: availability.unavailabilityReason,
        receiveOffersOffline: availability.receiveOffersOffline,
      ).toJson();

      await client.from('availability').update(payload).eq('id', availability.id);
    } catch (e) {
      throw Exception('Error updating availability: $e');
    }
  }
}
