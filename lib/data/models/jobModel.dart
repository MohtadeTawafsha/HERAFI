import 'package:herafi/domain/entites/customer.dart';

import '../../domain/entites/job.dart';
import 'customerModel.dart';

class JobModel extends JobEntity {
  JobModel({
    required int id,
    required String city,
    required String description,
    required DateTime createdAt,
    required String status,
    required String title,
    required String image,
    required String mapLatitude,
    required String mapLongitude,
    required String categoryName,
    required bool visibilityAllTypes,
    required CustomerEntity customer,
  }) : super(
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
    customer: customer
  );

  factory JobModel.fromJson(Map<String, dynamic> json) {
    Map<String,dynamic> customerData=json['customer'];
    customerData={...customerData,...json["customer"]['users']};
    customerData.remove('users');
    return JobModel(
      id: json['id'],
      city: json['city'],
      description: json['description'],
      createdAt: DateTime.parse(json['created-at']),
      status: json['status'],
      title: json['title'],
      image: json['image'],
      mapLatitude: json['map_latitude'],
      mapLongitude: json['map_longitude'],
      categoryName: json['category-name'],
      visibilityAllTypes: json['visibility_all_types'],
      customer: CustomerModel.fromJson(customerData),//in case we added new attribute in future
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id':customer.id,
      'city': city,
      'description': description,
      'created-at': createdAt.toIso8601String(),
      'status': status,
      'title': title,
      'image': image,
      'map_latitude': mapLatitude,
      'map_longitude': mapLongitude,
      'category-name': categoryName,
      'visibility_all_types': visibilityAllTypes,
    };
  }
}
