import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/status/error/Failure.dart';
import '../../domain/entites/chat.dart';
import '../../domain/entites/user.dart';
import '../../domain/usecases/chatUseCases/fetchUserChats.dart';
import '../../domain/usecases/chatUseCases/fetchUserData.dart';
import '../routes/app_routes.dart';

class crossData extends GetxController{
  final fetchUserChatsUseCase fetchChatsUseCase;
  final fetchUserDataUseCase FetchUserData;

  crossData({required this.fetchChatsUseCase,required this.FetchUserData});
  late UserEntity userEntity;
  RxList<chatEntity> chats = <chatEntity>[].obs;



  Future fetchChats() async {
    Either<Failure, List<chatEntity>> chats = await fetchChatsUseCase(userId: FirebaseAuth.instance.currentUser!.uid);
    chats.fold((ifLeft) {
      Get.snackbar('مشكلة', 'لقد حدثة مشكلة اثناء تحميل الرسائل');
    }, (ifRight) {
      this.chats.value=ifRight;
    });
  }


  Future<bool> fetchUserData()async{
    final result=await FetchUserData(userId: FirebaseAuth.instance.currentUser!.uid);
    return result.fold(
            (left){
          Get.snackbar('خطا', 'لقد حدث خطا ما يرجى المحاولة مرة اخرى');
          return false;
        },
            (right) {
              if (right != null) {
                Get
                    .find<crossData>()
                    .userEntity = right;
                return true;
              }
              return false;
            });
  }
}