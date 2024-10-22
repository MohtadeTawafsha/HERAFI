import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'app_routes.dart';

class initialPage{
  static bool? isLogIn;
  void handleInitialPage(snapshot){
    final User? user=snapshot[0];
    final ConnectivityResult connectivity=snapshot[1][0];
    if(!connectivity.name.contains('none')){
      if(user!=null){
        if(isLogIn!=true){
          isLogIn=true;
          Get.offAllNamed(AppRoutes.home);
        }
      }
      else{
        isLogIn=false;
        Get.offAllNamed(AppRoutes.introduction);
      }
    }
    else
      Get.offAllNamed(AppRoutes.noInternetConnection);

  }

}