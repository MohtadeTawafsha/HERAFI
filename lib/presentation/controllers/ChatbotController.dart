import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

import '../pages/orderProcessPage/resultBotPage.dart';

class ChatbotController extends GetxController {
  final TextEditingController textController=TextEditingController();
  // Initialize OpenAI instance
  late OpenAI openAI;
  String res="";
  // Observables for managing loading state and messages
  var isLoading = false.obs;
  var chatMessages = <Messages>[Messages(role: Role.assistant,content: "مرحبا انا مستر حرفي. سوف اقدم لك المساعدة في ايجاد الحرفي المناسب لحالتك. تفضل في شرح المشكلة!")].obs;
  String? threadId;
  final String assistantId='asst_p6PPNuKhw74ifZTv4kuJoFeH';
  final double borderRadius=15;

  @override
  void onInit() {
    super.onInit();
    openAI = OpenAI.instance.build(
      token: "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", // Replace with your API key
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ),
      enableLog: true,
    );
    createThread();
  }

  Future createThread()async{
    final thread = await openAI.threads.v2.createThread();
    threadId=thread.id;
  }
  void createPrompt(String prompt) async {
    try {
      this.chatMessages.add(Messages(role: Role.user,content: prompt));
      isLoading.value=true;

      if(threadId==null){
        await createThread();
      }
      await openAI.threads.v2.messages.createMessage(
        threadId: threadId!,
        request: CreateMessage(
          role: "user",
          content: prompt,
        ),
      );
      await openAI.threads.v2.runs.createRun(
        threadId: threadId!,
        request: CreateRun(
          assistantId: assistantId,
        ),
      );


      late MessageDataResponse messages;
      double time=0;



      while(true){
        if(time>10){
          Get.snackbar("خطأ","لقد حدث خطأ الرجاء المحاولة مرة اخرى لاحقا");
          return;
        }
        await Future.delayed(Duration(milliseconds: 500)); // Wait for a few seconds
        messages = await openAI.threads.v2.messages.listMessage(threadId: threadId!);
        if(messages.data.length!=this.chatMessages.length-1 && messages.data.first.content.length!=0){
          break;
        };
        time+=0.5;
      }

      if (messages.data.isNotEmpty) {
          if(messages.data.first.content.first.text!.value.contains("{")){
            handleMap(messages.data.first.content.first.text!.value);
            this.chatMessages.add(Messages(role: Role.assistant,content:"تم اعطاء نتيجة"));
          }
          else{
            this.chatMessages.add(Messages(role: Role.assistant,content: messages.data.first.content.first.text?.value));
          }
          isLoading.value=false;
      } else {
      }
    } catch (e) {
      Get.snackbar("خطأ","لقد حدث خطأ الرجاء المحاولة مرة اخرى");
    }
  }

  void handleMap(String text){
    res=text;
    try{
      Map map=jsonDecode(text.substring(text.indexOf("{"),text.lastIndexOf('}')+1));
      Navigator.push(Get.context!, MaterialPageRoute(builder: (ctx)=>resultBot(result: map,)));
    }
    catch(e){
      print(e);
    }
  }
}
