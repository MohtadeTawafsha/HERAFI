import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'app_routes.dart';

class initialPage{
  void handleInitialPage(snapshot){
    print(snapshot);
    print('snapshot');
    final User? user=snapshot[0];
    final ConnectivityResult connectivity=snapshot[1][0];
    if(!connectivity.name.contains('none')){
      if(user!=null){
        if(!(Get.currentRoute.startsWith('/home'))){
          Get.offAllNamed(AppRoutes.home);
        }
      }
      else {
        Get.offAllNamed(AppRoutes.introduction);
      }
    }
    else
      Get.offAllNamed(AppRoutes.noInternetConnection);

  }

}