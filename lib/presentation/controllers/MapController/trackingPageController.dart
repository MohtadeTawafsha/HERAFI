import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:herafi/domain/entites/ProjectEntity.dart';
import 'package:herafi/presentation/Widgets/liveLocationMarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'package:geolocator/geolocator.dart' as geoLocator;
import '../../routes/app_routes.dart';

class trackingPageController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MapController mapController = MapController();
  late Rx<LocationData> userLocation;
  ProjectEntity projectEntity = Get.arguments;
  RxBool isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    getUserLocation();
  }

  ///one-one
  void getUserLocation() async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectEntity.id.toString())
          .get()
          .then((value) {
        userLocation = LocationData.fromMap(value.data()!).obs;
      });
      isLoading.value = false;
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        moveCameraToLocation(userLocation.value);
      });
      getStreamLocation();
    } catch (e) {
      print(e.toString());
    }
  }

  void getStreamLocation() {
    //get stream from firebase
    FirebaseFirestore.instance
        .collection('projects')
        .doc(projectEntity.id.toString())
        .snapshots()
        .listen((event) {
      print("new location");
      userLocation.value = LocationData.fromMap(event.data()!);
    });
  }

  void moveCameraToLocation(LocationData location) {
    mapController.move(LatLng(location.latitude!, location.longitude!), 13);
  }
}
