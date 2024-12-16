import 'package:get/get.dart';
import '../controllers/MapController/trackingPageController.dart';


class trackingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>trackingPageController());
  }
}
