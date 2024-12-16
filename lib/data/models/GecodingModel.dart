
import '../../domain/entites/GeocodingEntity.dart';

class GeocodingModel extends GeocodingEntity {

  GeocodingModel({
    required super.id,
    required super.name,
    required super.country,
    required super.state,
    required super.county,
    required super.label,
    required super.coordinates,
  });

  factory GeocodingModel.fromJson(Map<String, dynamic> json) {
    return GeocodingModel(
      id: json['properties']['id'],
      name: json['properties']['name'],
      country: json['properties']['country'],
      state: json['properties']['state']??"",
      county: json['properties']['county']??"",
      label: json['properties']['label'],
      coordinates: List<double>.from(json['geometry']['coordinates']),
    );
  }
}