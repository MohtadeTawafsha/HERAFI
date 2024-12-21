import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ProjectDetailsPage.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await supabaseClient
          .from('projects')
          .select('id, title, state')
          .eq('state', 'تم الإرسال للعميل'); // عرض المشاريع بانتظار الموافقة

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
        title: const Text('الإشعارات'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project['title'] ?? 'بدون عنوان'),
            subtitle: const Text('بانتظار الموافقة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.to(() => ProjectDetailsPage(
                projectId: project['id'],
              ));
            },
          );
        },
      ),
    );
  }
}
