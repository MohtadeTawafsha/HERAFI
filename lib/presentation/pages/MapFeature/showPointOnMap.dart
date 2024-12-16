import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../global/constants.dart';
import '../../Widgets/leadingAppBar.dart';
import '../../controllers/MapController/showPointOnMapController.dart';

class showPointOnMap extends StatelessWidget {
  const showPointOnMap({super.key});
  @override
  Widget build(BuildContext context) {
    final showPointOnMapController controller = Get.find();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
      AppBar(leading: leadingAppBar(), backgroundColor: Colors.transparent,title: Text('موقع العمل')),
      body: Stack(
        children: [
          SizedBox(
            child: map(controller),
            width: Get.width,
            height: Get.height,
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
              )),
        ],
      ),
    );
  }

  Widget map(showPointOnMapController controller) {
    return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
            initialCenter: controller.selectedMarker.value.point,
            initialZoom: 15,
            interactionOptions:
            InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom)),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          Obx(() {
            return MarkerLayer(markers: [controller.selectedMarker.value]);
          })
        ]);
  }
}
