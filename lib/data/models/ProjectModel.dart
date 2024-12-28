import 'package:herafi/domain/entites/ProjectEntity.dart';

import '../../domain/entites/ProjectStepEntity.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.title,
    super.price,
    super.startDate,
    super.endDate,
    super.customerId,
    super.craftsmanId,
    super.state = 'تم الإرسال للعميل',
    super.steps, // جديد
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'] ?? '',
      price: json['price'] != null ? json['price'].toDouble() : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      state: json['state'] ?? 'تم الإرسال للعميل',
      steps: json['steps'] != null
          ? (json['steps'] as List)
          .map((step) => ProjectStepEntity(
        stepNumber: step['step_number'],
        title: step['title'],
        price: step['price'].toDouble(),
        duration: step['duration'], // String
        isPaid: step['is_paid'],
      ))
          .toList()
          : null, // جديد
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'state': state,
      'steps': steps
          ?.map((step) => {
        'step_number': step.stepNumber,
        'title': step.title,
        'price': step.price,
        'duration': step.duration, // String
        'is_paid': step.isPaid,
      })
          .toList(),
    };
  }
}
