import 'package:get/get.dart';
import '../../data/repositroies/userRepositoryImp.dart';
import '../../domain/usecases/chatUseCases/fetchUserData.dart';
import '../controllers/AuthController/smsVerificationController.dart';


class smsVerificationBinding extends Bindings {
  @override
  void dependencies() {
    String verificationId=Get.arguments["verificationId"];
    String phoneNumber=Get.arguments["phoneNumber"];

    Get.put(smsVerificationController(verificationId: verificationId,phoneNumber: phoneNumber));
  }
}
