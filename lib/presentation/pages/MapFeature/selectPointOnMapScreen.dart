import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../global/constants.dart';
import '../../Widgets/leadingAppBar.dart';
import '../../controllers/MapController/selectPointOnMapScreenController.dart';

class selectPointOnMapScreen extends StatelessWidget {
  const selectPointOnMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final selectPointOnMapScreenController controller = Get.find();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          AppBar(leading: leadingAppBar(), backgroundColor: Colors.transparent,title: Text('اختيار الموقع')),
      body: Stack(
        children: [
          SizedBox(
            child: map(controller),
            width: Get.width,
            height: Get.height,
          ),
          Positioned(
            bottom: Get.height * .041,
            child: Container(
              width: Get.width * 0.8,
              margin: EdgeInsets.all(Get.width * .1),
              child: TextButton(
                  onPressed: controller.confirm, child: Text('تأكيد النقطة')),
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
              )),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),color: Theme.of(context).primaryColor,),
            width: Get.width,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: TextField(
                    focusNode: controller.focusNode,
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن الموقع',
                      prefixIcon: Icon(Icons.location_on_outlined,color: Theme.of(context).focusColor,size: 25.spMin,)
                    ),
                    onChanged:controller.onChange,
                  ),
                ),
                Obx(
                    (){
                      if(controller.isEmpty.value==false)
                      return Container(
                        constraints: BoxConstraints(maxHeight: Get.height*.2),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: controller.options.length,
                            itemBuilder: (context,index){
                              final item=controller.options[index];
                              return ListTile(
                                onTap: ()=>controller.selectPointOnMap(item),
                                title: Text(item.name,style: Theme.of(context).textTheme!.bodyMedium,),
                              );
                            },
                          ),
                        ),
                      );
                      else
                        return Container();
                    }
                )
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget map(selectPointOnMapScreenController controller) {
    return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
            onTap: (position, latlang) {
              controller.selectedMarker.value =
                  Marker(point: latlang, child: constants.marker);
            },
            initialCenter: controller.selectedMarker.value.point,
            initialZoom: 15,
            interactionOptions:
                InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom)),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          Obx(() {
            print(controller.selectedMarker);
            return MarkerLayer(markers: [controller.selectedMarker.value]);
          })
        ]);
  }
}
