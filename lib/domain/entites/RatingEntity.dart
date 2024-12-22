

import '../../data/models/RatingModel.dart';

class RatingEntity {
  final int id;
  final String craftsmanId;
  final String customerId;
  final int projectId;
  final int workPerfection;
  final int behavior;
  final int respectDeadlines;
  final String? comment;
  final DateTime createdAt;

  RatingEntity({
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

  // تحويل RatingEntity إلى RatingModel
  RatingModel toModel() {
    return RatingModel(
      id: id,
      craftsmanId: craftsmanId,
      customerId: customerId,
      projectId: projectId,
      workPerfection: workPerfection,
      behavior: behavior,
      respectDeadlines: respectDeadlines,
      comment: comment,
      createdAt: createdAt,
    );
  }
}