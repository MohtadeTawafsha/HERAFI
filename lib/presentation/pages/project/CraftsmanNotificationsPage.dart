import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'CraftsmanProjectDetailsPage.dart';

class CraftsmanNotificationsPage extends StatefulWidget {
  const CraftsmanNotificationsPage({Key? key}) : super(key: key);

  @override
  _CraftsmanNotificationsPageState createState() =>
      _CraftsmanNotificationsPageState();
}

class _CraftsmanNotificationsPageState
    extends State<CraftsmanNotificationsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApprovedProjects();
  }

  Future<void> fetchApprovedProjects() async {
    try {
      final response = await supabaseClient
          .from('projects')
          .select('id, title, state')
          .eq('state', 'تم الموافقة'); // عرض المشاريع الموافق عليها فقط

      setState(() {
        projects = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الإشعارات: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إشعارات الحرفي'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project['title'] ?? 'بدون عنوان'),
            subtitle: const Text('تمت الموافقة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.to(() => CraftsmanProjectDetailsPage(
                projectId: project['id'],
              ));
            },
          );
        },
      ),
    );
  }
}
