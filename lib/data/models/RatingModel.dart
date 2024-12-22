class RatingModel {
  final int id;
  final String craftsmanId;
  final String customerId;
  final int projectId;
  final int workPerfection;
  final int behavior;
  final int respectDeadlines;
  final String? comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.craftsmanId,
    required this.customerId,
    required this.projectId,
    required this.workPerfection,
    required this.behavior,
    required this.respectDeadlines,
    this.comment,
    required this.createdAt,
  });

  // تحويل JSON إلى RatingModel
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      craftsmanId: json['craftsman_id'],
      customerId: json['customer_id'],
      projectId: json['project_id'],
      workPerfection: json['work_perfection'],
      behavior: json['behavior'],
      respectDeadlines: json['respect_deadlines'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // تحويل RatingModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'craftsman_id': craftsmanId,
      'customer_id': customerId,
      'project_id': projectId,
      'work_perfection': workPerfection,
      'behavior': behavior,
      'respect_deadlines': respectDeadlines,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}