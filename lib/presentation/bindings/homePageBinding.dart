
import 'package:get/get.dart';
import 'package:herafi/data/remotDataSource/chatsRemotDataSource.dart';
import 'package:herafi/data/repositroies/ChatRepositoryImpl.dart';
import 'package:herafi/data/repositroies/userRepositoryImp.dart';
import 'package:herafi/domain/usecases/chatUseCases/fetchUserChats.dart';
import 'package:herafi/domain/usecases/chatUseCases/fetchUserData.dart';

import '../controllers/AuthController/homePageController.dart';

class homePageBinding extends Bindings {
  @override
  void dependencies() {



    Get.put(homePageController());
  }
}