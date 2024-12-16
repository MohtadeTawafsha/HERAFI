import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class userRemotDataSource{
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<Map<String,dynamic>?> fetchUserData({required String userId})async{
    return await supabaseClient
        .from('users')
        .select('*, customer(*),craftsman(*)') // Fetch associated user data from 'users' table
        .eq('id', userId)
        .maybeSingle();

  }
}