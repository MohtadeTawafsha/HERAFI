import '../../domain/entites/ProjectEntity.dart';

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
  });

  /// Factory method to create a `ProjectModel` from JSON
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
    );
  }

  /// Convert `ProjectModel` to JSON
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
    };
  }
}
