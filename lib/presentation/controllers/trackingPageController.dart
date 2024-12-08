import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:herafi/presentation/Widgets/liveLocationMarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'package:geolocator/geolocator.dart' as geoLocator;
import '../routes/app_routes.dart';


class trackingPageController extends GetxController{

  final GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();
  MapController mapController=MapController();
  RxList<Marker> markers=<Marker>[].obs;
  late Rx<LocationData> userLocation;


  @override
  void onInit() {
    super.onInit();
    getUserLocation();
  }
///one-one
  void getUserLocation()async{
    try{
      var location=Location();
      await location.requestPermission();
      userLocation=(await location.getLocation()).obs;
        markers.value.add(Marker(point: LatLng(userLocation.value.latitude!,userLocation.value.longitude!), child: liveLocationMarker(),width: 100,height: 100));
         moveCameraToLocation(userLocation.value);
      markers.refresh();
      getStreamLocation();
    }
    catch(e){
      print(e.toString());
    }
  }
  void getStreamLocation(){

    final geoLocator.LocationSettings locationSettings = geoLocator.LocationSettings(
      accuracy: geoLocator.LocationAccuracy.high,
      distanceFilter: 1,
    );

    geoLocator.Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (geoLocator.Position? position) {
              if(position==null)return;
              userLocation.value=LocationData.fromMap({"latitude":position!.latitude,"longitude":position.longitude});
              markers.removeLast();
              markers.value.add(Marker(point: LatLng(position.latitude,position.longitude), child: liveLocationMarker(),width: 100,height: 100));
              moveCameraToLocation(userLocation.value);
              markers.refresh();
        });
  }
  void openDrawer(){
    scaffoldKey.currentState!.openDrawer();
  }
  void closeDrawer(){
    scaffoldKey.currentState!.closeDrawer();
  }
  void navigateProfilePage(){
    Get.toNamed(AppRoutes.profile);
  }
  void navigateSettingPage(){
    Get.toNamed(AppRoutes.setting);
  }
  void navigateOrderHistoryPage(){
    Get.toNamed(AppRoutes.orderHistory);
  }
  void moveCameraToLocation(LocationData location){
    mapController.move(LatLng(location.latitude!,location.longitude!), mapController.camera.zoom);
  }
}