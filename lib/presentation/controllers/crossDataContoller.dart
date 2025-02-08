import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;
import '../../core/status/error/Failure.dart';
import '../../domain/entites/chat.dart';
import '../../domain/entites/user.dart';
import '../../domain/usecases/chatUseCases/fetchUserChats.dart';
import '../../domain/usecases/chatUseCases/fetchUserData.dart';
import '../routes/app_routes.dart';

class crossData extends GetxController {
  final fetchUserChatsUseCase fetchChatsUseCase;
  final fetchUserDataUseCase FetchUserData;

  crossData({required this.fetchChatsUseCase, required this.FetchUserData});
  late UserEntity? userEntity;
  RxList<chatEntity> chats = <chatEntity>[].obs;

  MapController mapController = MapController();
  late Rx<LocationData> userLocation;

  Future fetchChats() async {
    Either<Failure, List<chatEntity>> chats =
        await fetchChatsUseCase(userId: FirebaseAuth.instance.currentUser!.uid);
    chats.fold((ifLeft) {
      Get.snackbar('مشكلة', 'لقد حدثة مشكلة اثناء تحميل الرسائل');
    }, (ifRight) {
      this.chats.value = ifRight;
    });
  }

  Future<bool> fetchUserData() async {
    final result =
        await FetchUserData(userId: FirebaseAuth.instance.currentUser!.uid);
    return result.fold((left) {
      Get.snackbar('خطا', 'لقد حدث خطا ما يرجى المحاولة مرة اخرى');
      return false;
    }, (right) {
      if (right != null) {
        Get.find<crossData>().userEntity = right;
        return true;
      }
      return false;
    });
  }

  void cleanData() {
    chats.clear();
    userEntity = null;
  }

  //enable tracking
  void enableTracking(String projectId) async {
    print('enableTracking');
    final result = await getUserLocation();
    result.fold((ifLeft) {
      Get.snackbar('خطا', 'لقد حدث خطا ما يرجى المحاولة مرة اخرى');
    }, (ifRight) {
      FirebaseFirestore.instance.collection('projects').doc(projectId).set({
        'latitude': ifRight.latitude,
        'longitude': ifRight.longitude,
      });
      getStreamLocation(projectId);
    });
  }

  Future<Either<Failure, LocationData>> getUserLocation() async {
    try {
      var location = Location();
      await location.requestPermission();
      userLocation = (await location.getLocation()).obs;
      return Right(userLocation.value);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  void getStreamLocation(String projectId) {
    final geoLocator.LocationSettings locationSettings =
        geoLocator.LocationSettings(
      accuracy: geoLocator.LocationAccuracy.high,
      distanceFilter: 1,
    );
    geoLocator.Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((geoLocator.Position? position) {
      if (position == null) return;
      FirebaseFirestore.instance.collection('projects').doc(projectId).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      print('position updated');
    });
  }
}
