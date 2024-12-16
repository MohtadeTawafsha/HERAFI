import '../entites/GeocodingEntity.dart';
import '../repositories/geocodingRepository.dart';

class GetSuggestionsUseCase {
  final GeocodingRepository repository;

  GetSuggestionsUseCase(this.repository);

  Future<List<GeocodingEntity>> call(String query) async {
    return await repository.getSuggestions(query);
  }
}
