import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/main.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import '../../../domain/usecases/chatUseCases/fetchUserData.dart';
import '../../../global/alers.dart';
import '../../Widgets/progressIndicator.dart';
import '../../routes/app_routes.dart';
class smsVerificationController extends GetxController{

  smsVerificationController({required this.verificationId,required this.phoneNumber});



  var timer = 60.obs;
  String verificationId;
  final String phoneNumber;
  final TextEditingController smsCodeController=TextEditingController();
  final Rx<bool> isCodeFull=false.obs;
  final Rx<String> errorMessage="".obs;


  @override
  void onInit() {
    super.onInit();
    startTimer();
  }
  void startTimer()async{
    while(true){
      if(timer!=0)
        timer.value=timer.value-1;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void goBack(){
    Get.back();
  }
  void sendCode()async{

    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber:phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          alerts().showErrorSnackBar(Get.context!, "لقد حدثة مشكلة ما تأكد من الرقم وحاول مرة اخرى");
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationId=verificationId;
          timer.value=60;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );

    }
    catch(e){
    }

  }
  void verifyNumber()async{
    Get.dialog(
      Center(
        child: progressIndicator(),
      ),
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
    );
    try{
      PhoneAuthCredential credential =await PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCodeController.text);

      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    on FirebaseAuthException catch(e){
      if(e.code=="invalid-verification-code"){
        errorMessage.value="رقم التأكيد غير صحيح يرجى المحاولة مرة اخرى";
        smsCodeController.clear();
      }
      else{
        errorMessage.value="لقد حدث خطأ غير متوقع الرجاء المحاولة مرة اخرى";
        smsCodeController.clear();
      }
    }
    catch(e){
      errorMessage.value="لقد حدث خطأ غير متوقع الرجاء المحاولة مرة اخرى";
      smsCodeController.clear();

    }
  }

}