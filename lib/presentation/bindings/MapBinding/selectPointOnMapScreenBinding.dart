import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../../../data/repositroies/GeocodingRepositoryImp.dart';
import '../../../domain/usecases/GetSuggestionsUseCase.dart';
import '../../../global/constants.dart';
import '../../controllers/MapController/selectPointOnMapScreenController.dart';

class selectPointOnMapScreenBinding extends Bindings {
  @override
  void dependencies() {
    Rx<Marker> selectedMarker = Marker(point: Get.arguments??constants.mapInitialLocation, child: constants.marker).obs;
    Get.lazyPut(()=>GeocodingRepositoryImpl());
    Get.lazyPut(()=>GetSuggestionsUseCase(Get.find<GeocodingRepositoryImpl>()));
    Get.put(selectPointOnMapScreenController(
        selectedMarker: selectedMarker,
      getSuggestionsUseCase: Get.find<GetSuggestionsUseCase>()
    ));
  }
}
