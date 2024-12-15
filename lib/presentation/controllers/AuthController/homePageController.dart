import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:herafi/domain/entites/chat.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/domain/usecases/chatUseCases/fetchUserChats.dart';
import 'package:herafi/presentation/routes/app_routes.dart';

import '../../../core/status/error/Failure.dart';
import '../../../domain/usecases/chatUseCases/fetchUserData.dart';
class homePageController extends GetxController {

  homePageController();
  Rx<int> index = 0.obs;
  List list = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void orderherafi() {
    Get.toNamed(AppRoutes.orderherafi);
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState!.closeDrawer();
  }

  void navigateProfilePage() {
    Get.toNamed(AppRoutes.profile);
  }

  void navigateSettingPage() {
    Get.toNamed(AppRoutes.setting);
  }

  void navigateOrderHistoryPage() {
    Get.toNamed(AppRoutes.orderHistory);
  }

  bool isSelected(int index) {
    return index == this.index.value;
  }

  void selectItem(int selectedItem) {
    index.value = selectedItem;
  }

  void toChats() {
    Get.toNamed(AppRoutes.chatspage);
  }
  void toChatBot() {
    Get.toNamed(AppRoutes.chatbot);
  }
}