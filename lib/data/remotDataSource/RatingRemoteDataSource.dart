import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/RatingModel.dart';

class RatingRemoteDataSource {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  // إضافة تقييم جديد
  Future<void> addRating(RatingModel rating) async {
    await supabaseClient.from('ratings').insert(rating.toJson());
  }

  // جلب التقييمات حسب الـ craftsman_id
  Future<List<RatingModel>> fetchRatingsByCraftsman(String craftsmanId) async {
    final response = await supabaseClient
        .from('ratings')
        .select()
        .eq('craftsman_id', craftsmanId);

    return (response as List).map((data) => RatingModel.fromJson(data)).toList();
  }
}