import 'package:herafi/domain/entites/ProjectEntity.dart';

import '../../domain/entites/ProjectStepEntity.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.title,
    required super.price,
    required super.startDate,
    required super.endDate,
    required super.customerId,
    required super.craftsmanId,
    super.state = 'تم الإرسال للعميل',
    required super.isCraftsmanConfirm,
    required super.isCustomerConfirm,
    required super.isRatingHappen,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return ProjectModel(
      id: json['id'],
      title: json['title'],
      price: json['price'] != null ? json['price'].toDouble() : null,
      startDate:DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      customerId: json['customer_id'],
      craftsmanId: json['craftsman_id'],
      state: json['state'] ?? 'تم الإرسال للعميل',
      isCraftsmanConfirm: json['isCraftsmanConfirm'],
      isCustomerConfirm: json['isCustomerConfirm'],
      isRatingHappen: (json['ratings'] as List).isNotEmpty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'customer_id': customerId,
      'craftsman_id': craftsmanId,
      'state': state,
      'isCraftsmanConfirm': isCraftsmanConfirm,
      'isCustomerConfirm': isCustomerConfirm,
    };
  }
}
