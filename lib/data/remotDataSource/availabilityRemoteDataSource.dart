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
    final response = await client
        .from('availability')
        .select()
        .eq('craftsman_id', craftsmanId);

    final data = response as List<dynamic>;
    return data
        .map((json) => AvailabilityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new availability record
  Future<void> addAvailability(AvailabilityEntity availability) async {
    final payload = AvailabilityModel(
      id: null, // تأكد من أن id غير موجود لأن قاعدة البيانات ستولده تلقائيًا
      craftsmanId: availability.craftsmanId,
      availabilityType: availability.availabilityType,
      dayOfWeek: availability.dayOfWeek,
      available: availability.available,
      unavailabilityReason: availability.unavailabilityReason,
    ).toJson();

    // إزالة id من JSON إذا كان null لتجنب إرساله
    payload.remove('id');

    await client.from('availability').insert(payload);
  }

  /// Update an existing availability record
  Future<void> updateAvailability(AvailabilityEntity availability) async {
    if (availability.id == null) {
      throw ArgumentError('ID is required for updating availability.');
    }

    final payload = AvailabilityModel(
      id: availability.id,
      craftsmanId: availability.craftsmanId,
      availabilityType: availability.availabilityType,
      dayOfWeek: availability.dayOfWeek,
      available: availability.available,
      unavailabilityReason: availability.unavailabilityReason,
    ).toJson();

    await client.from('availability').update(payload).eq('id', availability.id as Object);
  }
}