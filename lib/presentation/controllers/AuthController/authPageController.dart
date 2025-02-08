import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/global/alers.dart';
import '../../../global/setOfMethods.dart';
import '../../routes/app_routes.dart';

class authPageController extends GetxController{
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final TextEditingController textFiledController=TextEditingController();
  String countryCode='+970';


  void verify(){
    if(key.currentState!.validate()){
      sendVerificationCode();
    }
  }

  String? validPhoneNumber(String? phoneNumber){
    if(phoneNumber==null || phoneNumber.isEmpty)
      return "لا يمكن ان يكون الحقل فارغا";
    if(phoneNumber.length!=9)
      return "يرجى ادخال رقم صحيح";
    return null;
  }

  void sendVerificationCode()async{
    final String phoneNumber='+970'+textFiledController.text;
    globalMethods().showProgressDialog();
    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+970'+textFiledController.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e){
          Get.back();
          alerts().showErrorSnackBar(Get.context!, "لقد حدثة مشكلة ما تأكد من الرقم وحاول مرة اخرى");
        },
        codeSent: (String verificationId, int? resendToken)async{
          await Get.toNamed(AppRoutes.smsVerification,arguments: {"verificationId":verificationId,"phoneNumber":phoneNumber});
          Get.back();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );

    }
    catch(e){

    }

  }

}