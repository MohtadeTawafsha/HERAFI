import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:herafi/presentation/controllers/AuthController/smsVerificationController.dart';
import 'package:pinput/pinput.dart';
import '../../themes/colors.dart';

class smsVerificationPage extends StatelessWidget {
  const smsVerificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: min(MediaQuery.sizeOf(context).width*0.14, 56),
      height: 56,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Theme.of(context).focusColor,
      ),
    );

    final smsVerificationController controller = Get.find();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              color: ThemeColors.goldColor,
              onPressed: controller.goBack,
              icon: Icon(
                Icons.arrow_back_ios_new,
              )),
          actions: [trailing(controller)],
          backgroundColor: Colors.transparent,
          title:
              Text("تاكيد رقم الهاتف", style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text('لقد تم ارسال رقم تاكيد يرجى ادخاله والاتسمرار'),
                  SizedBox(
                    height: 30,
                  ),

                  Row(
                    children: [
                      Pinput(
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        controller: controller.smsCodeController,
                        pinContentAlignment: Alignment.center,
                        length: 6,
                        onChanged: (x)=>controller.isCodeFull.value=(x.length==6),

                      )
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      Obx((){
                        return Text(controller.errorMessage.value);
                      })
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx((){
                        return TextButton(onPressed: controller.isCodeFull.value?controller.verifyNumber:null, child: Text("تاكيد الرقم"));
                      })
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget resendCode(smsVerificationController controller) {
    return TextButton(onPressed:controller.sendCode, child: Text('resend'));
  }

  Widget trailing(smsVerificationController controller) {
    return Obx(() {
      if (controller.timer == 0)
        return resendCode(controller);
      else
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${controller.timer}',
            style: TextStyle(color: Colors.white),
          ),
        );
    });
  }
}
