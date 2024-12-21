import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectPage extends StatefulWidget {
  final String customerId;
  final String craftsmanId;

  const ProjectPage({
    Key? key,
    required this.customerId,
    required this.craftsmanId,
  }) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  // بيانات العميل والحرفي
  Map<String, dynamic>? customerData;
  Map<String, dynamic>? craftsmanData;

  // حقول إدخال المشروع
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // جلب بيانات العميل عبر جدول users
      final customerResponse = await supabaseClient
          .from('users')
          .select('name, phone_number, image')
          .eq('id', widget.customerId)
          .maybeSingle();

      // جلب بيانات الحرفي عبر جدول users
      final craftsmanResponse = await supabaseClient
          .from('users')
          .select('name, phone_number, image')
          .eq('id', widget.craftsmanId)
          .maybeSingle();

      if (customerResponse == null || craftsmanResponse == null) {
        throw Exception('Customer or craftsman not found');
      }

      setState(() {
        customerData = customerResponse;
        craftsmanData = craftsmanResponse;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب بيانات المشروع: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> saveProject() async {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع الحقول المطلوبة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // التحقق مما إذا كان المشروع موجودًا بالفعل
      final existingProject = await supabaseClient
          .from('projects')
          .select('id') // إرجاع المعرف فقط للتحقق
          .eq('customer_id', widget.customerId)
          .eq('craftsman_id', widget.craftsmanId)
          .maybeSingle();

      if (existingProject != null) {
        // إذا كان المشروع موجودًا، قم بتحديثه
        await supabaseClient.from('projects').update({
          'title': titleController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'state': 'تم الإرسال للعميل',
        }).eq('id', existingProject['id']); // تحديث المشروع بناءً على المعرف

        Get.snackbar(
          'نجاح',
          'تم تحديث المشروع بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // إذا لم يكن المشروع موجودًا، قم بإنشائه
        await supabaseClient.from('projects').insert({
          'title': titleController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'customer_id': widget.customerId,
          'craftsman_id': widget.craftsmanId,
          'state': 'تم الإرسال للعميل',
        });

        Get.snackbar(
          'نجاح',
          'تم حفظ المشروع بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ المشروع: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بيانات العميل
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: customerData?['image'] != null
                        ? NetworkImage(customerData!['image'])
                        : AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerData?['name'] ?? 'Unknown Customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        customerData?['phone_number'] ?? 'No phone number',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // بيانات الحرفي
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: craftsmanData?['image'] != null
                        ? NetworkImage(craftsmanData!['image'])
                        : AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        craftsmanData?['name'] ?? 'Unknown Craftsman',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        craftsmanData?['phone_number'] ?? 'No phone number',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // عنوان المشروع
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المشروع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // سعر المشروع
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'سعر المشروع',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // اختيار تاريخ البداية
              Row(
                children: [
                  const Text('تاريخ البداية:'),
                  const SizedBox(width: 10),
                  Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'لم يتم التحديد',
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => pickDate(context, true),
                    child: const Text('اختر التاريخ'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // اختيار تاريخ النهاية
              Row(
                children: [
                  const Text('تاريخ النهاية:'),
                  const SizedBox(width: 10),
                  Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'لم يتم التحديد',
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => pickDate(context, false),
                    child: const Text('اختر التاريخ'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // زر حفظ
              Center(
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveProject,
                  child: isSaving
                      ? const CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
