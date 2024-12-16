import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entites/GeocodingEntity.dart';
import '../../../domain/usecases/GetSuggestionsUseCase.dart';
import '../../../global/constants.dart';


class showPointOnMapController extends GetxController{
  final GetSuggestionsUseCase getSuggestionsUseCase;

  RxBool isEmpty=false.obs;
  Rx<Marker> selectedMarker;
  MapController mapController=MapController();
  RxList<GeocodingEntity> options=<GeocodingEntity>[].obs;
  Map<String,List<GeocodingEntity>> previousResult={};
  final TextEditingController searchController=TextEditingController();
  final FocusNode focusNode=FocusNode();

  showPointOnMapController({required this.selectedMarker,required this.getSuggestionsUseCase});
  void confirm(){
    Get.back(result: selectedMarker.value.point);
  }

  @override
  void onInit() {
    super.onInit();
  }


  void onChange(String text)async{
    isEmpty.value=text.isEmpty;
    if(previousResult[text]!=null){
      options.value=previousResult[text]!;
      return;
    }
    final x=await getSuggestionsUseCase(text);
    options.value=x;
    previousResult[text]=x;

  }
  void selectPointOnMap(GeocodingEntity entity){
    LatLng coordinates=LatLng(entity.coordinates[1], entity.coordinates[0]);
    mapController.move(coordinates, 15);
    selectedMarker.value=Marker(point: coordinates, child: constants.marker);
    searchController.clear();
    isEmpty.value=true;
    FocusScope.of(Get.context!).unfocus();
  }
}