// الكود الكامل المحدث لإدخال خطوات المشروع مع حل مشكلة NUMERIC(10, 2)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/data/repositroies/ProjectRepositoryImpl.dart';
import 'package:herafi/domain/entites/ProjectStepEntity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/remotDataSource/ProjectRemoteDataSource.dart';
import '../../../domain/entites/ProjectEntity.dart';
import '../../../domain/repositories/ProjectRepository.dart';
import '../../../global/project_states.dart';

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
  late final ProjectRepository projectRepository;
  ProjectEntity? project;

  // بيانات العميل والحرفي
  Map<String, dynamic>? customerData;
  Map<String, dynamic>? craftsmanData;

  // الحقول الرئيسية
  final TextEditingController titleController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  // الحقول الخاصة بتقسيم المشروع إلى دفعات
  bool isStepsEnabled = false;
  List<Map<String, dynamic>> projectSteps = [];
  final TextEditingController stepTitleController = TextEditingController();
  final TextEditingController stepPriceController = TextEditingController();
  final TextEditingController stepDurationController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    setupRepository();
    fetchProjectData();
  }

  void setupRepository() {
    if (!Get.isRegistered<ProjectRepository>()) {
      final supabaseClient = Supabase.instance.client;
      final projectRemoteDataSource = ProjectRemoteDataSource(supabaseClient);
      Get.put<ProjectRepository>(
        ProjectRepositoryImpl(projectRemoteDataSource),
      );
    }
    projectRepository = Get.find<ProjectRepository>();
  }

  Future<void> fetchProjectData() async {
    try {
      setState(() {
        isLoading = true;
      });

      customerData = await projectRepository.fetchUserDetails(widget.customerId);
      craftsmanData = await projectRepository.fetchUserDetails(widget.craftsmanId);

      final result = await projectRepository.fetchProjectById(
        int.parse(widget.customerId),
      );

      result.fold(
            (failure) => showError('فشل في جلب بيانات المشروع: ${failure.message}'),
            (fetchedProject) {
          setState(() {
            project = fetchedProject;
            titleController.text = fetchedProject.title;
            totalPriceController.text = fetchedProject.price?.toString() ?? '';
            startDate = fetchedProject.startDate;
            endDate = fetchedProject.endDate;
          });
        },
      );
    } catch (error) {
      showError('حدث خطأ أثناء جلب البيانات: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> doesProjectExist(int projectId) async {
    final response = await Supabase.instance.client
        .from('projects')
        .select('id')
        .eq('id', projectId)
        .maybeSingle();

    return response != null;
  }

  double? parsePrice(String priceText) {
    try {
      double price = double.parse(priceText);
      return double.parse(price.toStringAsFixed(2)); // تقليل عدد الأرقام العشرية إلى 2
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProject() async {
    if (titleController.text.isEmpty ||
        totalPriceController.text.isEmpty ||
        startDate == null ||
        endDate == null ||
        (isStepsEnabled && projectSteps.isEmpty)) {
      showError('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    final totalPrice = parsePrice(totalPriceController.text);
    if (totalPrice == null) {
      showError('يرجى إدخال سعر كلي صالح');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // إدخال المشروع
      int projectId = project?.id ?? 0;
      if (projectId == 0) {
        final result = await projectRepository.insertProject(ProjectEntity(
          id: 0,
          title: titleController.text,
          price: totalPrice,
          startDate: startDate,
          endDate: endDate,
          customerId: widget.customerId,
          craftsmanId: widget.craftsmanId,
          state: projectStates[0],
        ));

        result.fold(
              (failure) {
            showError('فشل في إدخال المشروع: ${failure.message}');
            return;
          },
              (_) async {
            // الحصول على المشروع الجديد لتحديد project_id
            final newProject = await projectRepository.fetchProjectByCustomerAndCraftsman(
                widget.customerId, widget.craftsmanId);
            projectId = newProject.id;
          },
        );
      }

      // إدخال الخطوات
      if (isStepsEnabled && projectSteps.isNotEmpty) {
        for (var step in projectSteps) {
          final stepPrice = parsePrice(step['price'].toString());
          if (stepPrice == null) {
            showError('يرجى إدخال سعر صالح للخطوة: ${step['title']}');
            continue;
          }

          await projectRepository.insertProjectStep(
            projectId,
            ProjectStepEntity(
              stepNumber: projectSteps.indexOf(step) + 1,
              title: step['title'],
              price: stepPrice,
              duration: step['duration'],
            ),
          );
        }
      }

      await updateProjectState(projectStates[1]);
      setState(() {
        successMessage = 'بانتظار موافقة العميل ${customerData?['name']}';
      });
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          successMessage = null;
        });
      });
    } catch (error) {
      showError('حدث خطأ أثناء حفظ المشروع: ${error.toString()}');
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> updateProjectState(String newState) async {
    if (project == null) return;

    try {
      await projectRepository.updateProjectState(project!.id, newState);
      setState(() {
        project!.state = newState;
      });
    } catch (error) {
      showError('فشل في تحديث حالة المشروع: ${error.toString()}');
    }
  }

  void showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildUserInfoSection(' العميل', customerData),
                    const SizedBox(height: 16),
                    buildUserInfoSection(' الحرفي', craftsmanData),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان المشروع',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: totalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر الكلي',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('تاريخ البداية: '),
                        const SizedBox(width: 10),
                        Text(
                          startDate != null
                              ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                              : 'لم يتم التحديد',
                        ),
                        ElevatedButton(
                          onPressed: () => pickDate(context, true),
                          child: const Text('اختر التاريخ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('تاريخ النهاية: '),
                        const SizedBox(width: 10),
                        Text(
                          endDate != null
                              ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                              : 'لم يتم التحديد',
                        ),
                        ElevatedButton(
                          onPressed: () => pickDate(context, false),
                          child: const Text('اختر التاريخ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text("تقسيم المشروع إلى دفعات؟"),
                      value: isStepsEnabled,
                      onChanged: (value) {
                        setState(() {
                          isStepsEnabled = value!;
                          if (!isStepsEnabled) {
                            projectSteps.clear();
                          }
                        });
                      },
                    ),
                    if (isStepsEnabled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: stepTitleController,
                            decoration: const InputDecoration(
                              labelText: 'عنوان الخطوة',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: stepPriceController,
                            decoration: const InputDecoration(
                              labelText: 'سعر الخطوة',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: stepDurationController,
                            decoration: const InputDecoration(
                              labelText: 'مدة التنفيذ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (stepTitleController.text.isNotEmpty &&
                                  stepPriceController.text.isNotEmpty &&
                                  stepDurationController.text.isNotEmpty) {
                                final stepPrice = parsePrice(stepPriceController.text);
                                if (stepPrice == null) {
                                  showError('يرجى إدخال سعر صالح للخطوة');
                                  return;
                                }

                                setState(() {
                                  projectSteps.add({
                                    'title': stepTitleController.text,
                                    'price': stepPrice,
                                    'duration': stepDurationController.text,
                                  });
                                  stepTitleController.clear();
                                  stepPriceController.clear();
                                  stepDurationController.clear();
                                });
                              } else {
                                showError('يرجى ملء جميع الحقول الخاصة بالخطوة');
                              }
                            },
                            child: const Text('إضافة الخطوة'),
                          ),
                          const SizedBox(height: 16),
                          if (projectSteps.isNotEmpty)
                            ...projectSteps.map((step) => ListTile(
                              title: Text(step['title']),
                              subtitle: Text(
                                  'السعر: ${step['price']} | المدة: ${step['duration']}'),
                            )),
                        ],
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveProject,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text('حفظ'),
                    ),
                  ],
                ),
              ),
            ),
          if (successMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green,
                child: Text(
                  successMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildUserInfoSection(String title, Map<String, dynamic>? data) {
    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text('جاري التحميل...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: data['image'] != null
                  ? NetworkImage(data['image'])
                  : const AssetImage('assets/images/default_avatar.png')
              as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'غير معروف',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data['phone_number'] ?? 'غير معروف',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
