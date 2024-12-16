import '../../domain/entites/GeocodingEntity.dart';
import '../../domain/repositories/geocodingRepository.dart';
import '../remotDataSource/GeocodingDataSource.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {

  final GeocodingDataSourceImpl dataSource=GeocodingDataSourceImpl();

  @override
  Future<List<GeocodingEntity>> getSuggestions(String query) async {
    try {
      return await dataSource.getSuggestions(query);
    } catch (e) {
      throw Exception('Error getting suggestions');
    }
  }
}
