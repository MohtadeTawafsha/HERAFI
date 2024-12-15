import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';

import '../../data/remotDataSource/chatsRemotDataSource.dart';
import '../../data/repositroies/ChatRepositoryImpl.dart';
import '../../data/repositroies/userRepositoryImp.dart';
import '../../domain/usecases/chatUseCases/fetchUserChats.dart';
import '../../domain/usecases/chatUseCases/fetchUserData.dart';


class crossDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>chatsRemotDataSource());
    Get.lazyPut(()=>userRepositoryImp());

    Get.lazyPut(()=>ChatRepositoryImpl(Get.find<chatsRemotDataSource>()));
    Get.lazyPut(()=>fetchUserChatsUseCase(Get.find<ChatRepositoryImpl>()));

    Get.lazyPut(()=>fetchUserDataUseCase(userRepos: Get.find<userRepositoryImp>()));

    Get.put(crossData(fetchChatsUseCase: Get.find<fetchUserChatsUseCase>(),FetchUserData: Get.find<fetchUserDataUseCase>()),permanent: true);
  }
}
