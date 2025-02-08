import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:herafi/presentation/Widgets/liveLocationMarker.dart';
import 'package:latlong2/latlong.dart';
import '../../global/constants.dart';
import '../Widgets/progressIndicator.dart';
import '../controllers/MapController/trackingPageController.dart';
import '../themes/colors.dart';

class trackingPage extends StatelessWidget {
  const trackingPage({super.key});
  @override
  Widget build(BuildContext context) {
    final trackingPageController controller = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: Text('موقع الحرفي'),
          leading: leadingAppBar(),
        ),
        key: controller.scaffoldKey,
        body: Obx(() {
          return controller.isLoading.value
              ? Center(child: progressIndicator())
              : SizedBox(
                  child: map(controller),
                  width: Get.width,
                  height: Get.height,
                );
        }));
  }

  Widget map(trackingPageController controller) {
    return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
            initialCenter: LatLng(32.06502, 35.02554),
            initialZoom: 15,
            interactionOptions:
                InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom)),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          Obx(() {
            print(controller.userLocation);
            return MarkerLayer(markers: [
              Marker(
                  point: LatLng(controller.userLocation.value.latitude!,
                      controller.userLocation.value.longitude!),
                  child: liveLocationMarker(),
                  width: 100,
                  height: 100)
            ]);
          })
        ]);
  }
}
