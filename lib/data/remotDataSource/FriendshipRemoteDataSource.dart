import 'package:herafi/data/models/FriendshipModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendshipRemoteDataSource {
  final SupabaseClient client;

  FriendshipRemoteDataSource(this.client);

  /// Add a new friendship
  Future<void> addFriendship(FriendshipModel friendship) async {
    final response = await client.from('friendship').insert(friendship.toJson());
    if (response == null) {
      throw Exception('Failed to add friendship');
    }
  }

  /// Remove a friendship
  Future<void> removeFriendship(String craftsmanId, String customerId) async {
    final response = await client
        .from('friendship')
        .delete()
        .eq('craftsman_id', craftsmanId)
        .eq('customer_id', customerId);

    if (response == null) {
      throw Exception('Failed to remove friendship');
    }
  }

  /// Check if a customer follows a craftsman
  Future<bool> isFollowing(String craftsmanId, String customerId) async {
    final response = await client
        .from('friendship')
        .select('id')
        .eq('craftsman_id', craftsmanId)
        .eq('customer_id', customerId)
        .maybeSingle();

    return response != null;
  }

  /// Fetch all followers for a craftsman
  Future<List<FriendshipModel>> fetchFollowers(String craftsmanId) async {
    final response = await client
        .from('friendship')
        .select()
        .eq('craftsman_id', craftsmanId);

    if (response == null || response.isEmpty) {
      return [];
    }

    return (response as List)
        .map((json) => FriendshipModel.fromJson(json))
        .toList();
  }

  /// Fetch all craftsmen followed by a customer
  Future<List<FriendshipModel>> fetchFollowedCraftsmen(String customerId) async {
    final response = await client
        .from('friendship')
        .select()
        .eq('customer_id', customerId);

    if (response == null || response.isEmpty) {
      return [];
    }

    return (response as List)
        .map((json) => FriendshipModel.fromJson(json))
        .toList();
  }
}