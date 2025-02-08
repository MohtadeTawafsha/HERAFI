import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../states/RateCraftsmanScreen.dart';


class CraftsmanProjectDetailsPage extends StatefulWidget {
  final int projectId;
  final String craftsmanId; // أضف هذا للحصول على معرف الحرفي

  const CraftsmanProjectDetailsPage({
    Key? key,
    required this.projectId,
    required this.craftsmanId,
  }) : super(key: key);

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
          .select('title, price, start_date, end_date, craftsman_id') // أضف craftsman_id هنا
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



  Future<void> completeProjectWork() async {
    try {
      // تحقق من وجود معرف الحرفي
      if (projectDetails == null || projectDetails!['craftsman_id'] == null) {
        throw Exception('معرّف الحرفي مفقود.');
      }

      // تحديث حالة المشروع إلى "تم الانتهاء"
      await supabaseClient
          .from('projects')
          .update({'state': 'تم الانتهاء'})
          .eq('id', widget.projectId);

      Get.snackbar(
        'نجاح',
        'تم تحديث حالة المشروع إلى "تم الانتهاء".',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث حالة المشروع أو الانتقال: ${error.toString()}',
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
              'تاريخ البداية: ${projectDetails?['start_date']?.split('T')[0] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'تاريخ النهاية: ${projectDetails?['end_date']?.split('T')[0] ?? 'غير متوفر'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // زر إنهاء المشروع
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final craftsmanId = projectDetails?['craftsman_id'];
                  final projectId = projectDetails?['id'];

                  if (craftsmanId != null) {
                    Get.to(() => RateCraftsmanScreen(craftsmanId: craftsmanId, projectId: projectId,));
                  } else {
                    Get.snackbar(
                      'خطأ',
                      'لا يوجد معرّف للحرفي مرتبط بهذا المشروع.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('تم إنهاء العمل'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
