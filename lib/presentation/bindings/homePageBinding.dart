
import 'package:get/get.dart';
import 'package:herafi/data/remotDataSource/chatsRemotDataSource.dart';
import 'package:herafi/data/repositroies/ChatRepositoryImpl.dart';
import 'package:herafi/domain/usecases/chatUseCases/fetchUserChats.dart';

import '../controllers/AuthController/homePageController.dart';

class homePageBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut(()=>chatsRemotDataSource());
    Get.lazyPut(()=>ChatRepositoryImpl(Get.find<chatsRemotDataSource>()));
    Get.lazyPut(()=>fetchUserChatsUseCase(Get.find<ChatRepositoryImpl>()));
    Get.put(homePageController(fetchChatsUseCase: Get.find<fetchUserChatsUseCase>()));
  }
}
