
import 'package:get/get.dart';

import '../controllers/AuthController/homePageController.dart';

class homePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(homePageController());
  }
}
