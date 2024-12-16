import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/domain/entites/job.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jobModel.dart';
import 'certificateRemotDataSource.dart';

class JobRemoteDataSource {
  final SupabaseClient supabaseClient=Supabase.instance.client;

  Future<JobModel> getJobDetails(int id) async {
    try {
      final response = await supabaseClient
          .from('jobs') // 'jobs' is the table name
          .select("*, users(*),customer(*)")
          .eq('id', id) // Filter by ID
          .single()
          .select();


      final data = response as Map<String, dynamic>;
      return JobModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch job details: $e');
    }
  }
  Future createJob(JobModel job)async{
    final fileName = 'certificates/${DateTime.now().millisecondsSinceEpoch}';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putFile(File(job.image));
    job.image=await uploadTask.ref.getDownloadURL();
    await supabaseClient.from('jobs').insert(job.toJson());
  }

  Future<List<JobEntity>> fetchJobs(int page,String category) async {
    final response = await supabaseClient
        .from('jobs')
        .select('*, customer(*, users(*))') // Fetch customer and its related user
        .or('visibility_all_types.eq.true,category-name.eq.$category')
        .order('created-at', ascending: false)
        .range((page - 1) * 15, page * 15 - 1);




    return (response as List).map((json) => JobModel.fromJson(json)).toList();
  }
  Future<List<JobEntity>> searchJobs(String query, int page,String category) async {
    final response = await supabaseClient
        .from('jobs')
        .select('*, customer(*, users(*))')
        .or('visibility_all_types.eq.true,category-name.eq.$category')
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('created-at', ascending: false)
        .range((page - 1) * 15, page * 15 - 1)
        ;


    return (response as List)
        .map((json) => JobModel.fromJson(json))
        .toList();
  }
}
