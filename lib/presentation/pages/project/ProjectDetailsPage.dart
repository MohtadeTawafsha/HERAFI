import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectDetailsPage extends StatefulWidget {
  final int projectId;

  const ProjectDetailsPage({Key? key, required this.projectId})
      : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  Map<String, dynamic>? projectDetails;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
  }

  Future<void> fetchProjectDetails() async {
    try {
      final response = await supabaseClient
          .from('projects')
          .select('*')
          .eq('id', widget.projectId)
          .maybeSingle();

      setState(() {
        projectDetails = response;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب تفاصيل المشروع: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateProjectState(String newState) async {
    try {
      await supabaseClient
          .from('projects')
          .update({'state': newState})
          .eq('id', widget.projectId);

      setState(() {
        projectDetails?['state'] = newState;
      });

      Get.snackbar(
        'نجاح',
        'تم تحديث حالة المشروع إلى: $newState',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الحالة: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عنوان المشروع: ${projectDetails?['title'] ?? 'غير متوفر'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'السعر: ${projectDetails?['price'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'تاريخ البداية: ${projectDetails?['start_date'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'تاريخ النهاية: ${projectDetails?['end_date'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'حالة المشروع الحالية: ${projectDetails?['state'] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  updateProjectState('تم الموافقة');
                },
                child: const Text('الموافقة على المشروع'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
