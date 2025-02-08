import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/AuthController/homePageController.dart';
import 'package:herafi/presentation/routes/app_routes.dart';

import '../../../domain/entites/chat.dart';
import '../crossDataContoller.dart';

class chatsPageController extends GetxController{
  final homePageController HomePageController;
  final TextEditingController searchController=TextEditingController();
  Rx<List<chatEntity>> chats = Get.find<crossData>().chats.obs;

  chatsPageController({required this.HomePageController});

  @override
  void onInit() {
    super.onInit();
  }
  void toChatPage(chatEntity c){
    Get.toNamed(AppRoutes.chatpage,arguments: c);
  }
  Future handleRefreshIndicator()async{
    await Get.find<crossData>().fetchChats();
    chats.value=Get.find<crossData>().chats;
  }

}