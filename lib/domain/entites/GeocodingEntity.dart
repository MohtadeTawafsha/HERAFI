class GeocodingEntity {
  final String id;
  final String name;
  final String country;
  final String state;
  final String county;
  final String label;
  final List<double> coordinates;

  GeocodingEntity({
    required this.id,
    required this.name,
    required this.country,
    required this.state,
    required this.county,
    required this.label,
    required this.coordinates,
  });
}