import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entites/GeocodingEntity.dart';
import '../models/GecodingModel.dart';

class GeocodingDataSourceImpl  {
  final String apiKey="5b3ce3597851110001cf62486930ed970a56438f8fc44b3f1d8ea02e";
  final String baseUrl = 'https://api.openrouteservice.org/geocode/search';
  final String countryCode="PSE";


  Future<List<GeocodingEntity>> getSuggestions(String query) async {

    String url = '$baseUrl?api_key=$apiKey&text=$query';

    // Add the country restriction if provided
    url+="&boundary.country=PSE";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      Map combinedResults = json.decode(response.body);
      try{
        List<GeocodingEntity> result=[];
        List x=combinedResults["features"];

        for(Map<String,dynamic> element in x){
          try{
            result.add( GeocodingModel.fromJson(element));
          }
          catch(e){
          }
        }
        return result;
      }
      catch(e){
        return [];
      }
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
