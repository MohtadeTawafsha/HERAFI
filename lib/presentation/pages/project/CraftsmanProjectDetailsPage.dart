import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CraftsmanProjectDetailsPage extends StatefulWidget {
  final int projectId;

  const CraftsmanProjectDetailsPage({Key? key, required this.projectId})
      : super(key: key);

  @override
  _CraftsmanProjectDetailsPageState createState() =>
      _CraftsmanProjectDetailsPageState();
}

class _CraftsmanProjectDetailsPageState
    extends State<CraftsmanProjectDetailsPage> {
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
          .select('title, price, start_date, end_date')
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
          ],
        ),
      ),
    );
  }
}
