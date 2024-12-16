import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../../../data/repositroies/GeocodingRepositoryImp.dart';
import '../../../domain/usecases/GetSuggestionsUseCase.dart';
import '../../../global/constants.dart';
import '../../Widgets/liveLocationMarker.dart';
import '../../controllers/MapController/showPointOnMapController.dart';

class showPointOnMapBinding extends Bindings {
  @override
  void dependencies() {
    Rx<Marker> selectedMarker = Marker(point: Get.arguments??constants.mapInitialLocation, child: liveLocationMarker(),width: 100,height: 100).obs;
    Get.lazyPut(()=>GeocodingRepositoryImpl());
    Get.lazyPut(()=>GetSuggestionsUseCase(Get.find<GeocodingRepositoryImpl>()));
    Get.put(showPointOnMapController(
        selectedMarker: selectedMarker,
        getSuggestionsUseCase: Get.find<GetSuggestionsUseCase>()
    ));
  }
}
