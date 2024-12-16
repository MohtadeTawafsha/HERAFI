import 'package:herafi/data/models/jobModel.dart';

class JobEntity {
  final int id;
  final String city;
  final String description;
  final DateTime createdAt;
  final String status;
  final String title;
  String image;
  final String mapLatitude;
  final String mapLongitude;
  final String categoryName;
  final bool visibilityAllTypes;
  JobEntity({
    required this.id,
    required this.city,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.title,
    required this.image,
    required this.mapLatitude,
    required this.mapLongitude,
    required this.categoryName,
    required this.visibilityAllTypes,
  });
  JobModel toModel() {
    return JobModel(
      id: id,
      city: city,
      description: description,
      createdAt: createdAt,
      status: status,
      title: title,
      image: image,
      mapLatitude: mapLatitude,
      mapLongitude: mapLongitude,
      categoryName: categoryName,
      visibilityAllTypes: visibilityAllTypes,
    );
  }

}