import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:herafi/presentation/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class homePageController extends GetxController{
  Rx<int> index=0.obs;
  List list=[];
  final GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    //storeData();
  }

  void orderherafi(){
    Get.toNamed(AppRoutes.orderherafi);
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

  bool isSelected(int index){
    return index==this.index.value;
  }
  void selectItem(int selectedItem){
    index.value=selectedItem;
  }
  void makeCall(){
    
  }
  void storeData()async{
      //ORM
    try{
      final SupabaseClient supabaseClient = Supabase.instance.client;
      final result=await supabaseClient.from('users').insert({
        "id":FirebaseAuth.instance.currentUser!.uid,
        "name":FirebaseAuth.instance.currentUser!.displayName,
        "phone_number":FirebaseAuth.instance.currentUser!.phoneNumber,
        "user_type":"craftsman",
      });
      final result1=await supabaseClient
          .from('users')
          .select();
      print(result1);
    }
    catch(e){
      print(e.toString());
    }
  }
}