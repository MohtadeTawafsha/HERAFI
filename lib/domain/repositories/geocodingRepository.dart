import '../entites/GeocodingEntity.dart';

abstract class GeocodingRepository {
  Future<List<GeocodingEntity>> getSuggestions(String query);
}
