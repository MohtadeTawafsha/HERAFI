import 'dart:async';
import 'package:get/get.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

class ChatbotController extends GetxController {
  final TextEditingController textController=TextEditingController();
  // Initialize OpenAI instance
  late OpenAI openAI;
  // Observables for managing loading state and messages
  var isLoading = false.obs;
  var chatMessages = <Messages>[].obs;

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
  }
  Future<void> sendMessage(String message) async {
    update();
    isLoading.value=true;
    try {
      final request = ChatCompleteText(
        messages: [Messages(role: Role.assistant, content: message).toJson()],
        maxToken: 200,
        model: ChatModelFromValue(model: 'gpt-4o'),
      );

      chatMessages.add(Messages(role: Role.user, content: message));
      ChatCTResponse? response = await openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        // Update chat messages with user message and bot response
        chatMessages.add(Messages(role: Role.assistant, content: response.choices.first.message!.content));
      } else {
        Get.snackbar('خطأ', 'لم يتم استرداد الرد من الدردشة');
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالدردشة: $e');
    } finally {
      update();
    }

    isLoading.value=false;
  }
}
