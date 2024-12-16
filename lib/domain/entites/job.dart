import 'package:herafi/data/models/jobModel.dart';
import 'package:herafi/domain/entites/customer.dart';
import 'package:latlong2/latlong.dart';

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
  final CustomerEntity customer;
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
    required this.customer
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
      customer: customer
    );
  }
  String getDateFormat(){
    String date="";
    date+=(createdAt.month.toString()+"/");
    date+=(createdAt.day.toString()+"/");
    date+=(createdAt.year.toString());
    return date;
  }
  LatLng getLocationPoint(){
    print(LatLng(double.parse(mapLatitude), double.parse(mapLongitude)));
    return LatLng(double.parse(mapLatitude), double.parse(mapLongitude));
  }
}