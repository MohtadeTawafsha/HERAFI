import 'package:herafi/domain/entites/ProjectStepEntity.dart';

class ProjectEntity {
  final int id;
  final String title;
  final double? price;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? customerId;
  final String? craftsmanId;
  late final String state;
  final List<ProjectStepEntity>? steps; // جديد: قائمة بالخطوات

  ProjectEntity({
    required this.id,
    required this.title,
    this.price,
    this.startDate,
    this.endDate,
    this.customerId,
    this.craftsmanId,
    this.state = 'تم الإرسال للعميل',
    this.steps, // جديد
  });
}