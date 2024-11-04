import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ChatbotController.dart';

class ChatbotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the controller through Get
    final ChatbotController _controller = Get.find<ChatbotController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدردشة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display chat messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: _controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = _controller.chatMessages[index];
                  bool isUser=message.role.name.compareTo("user")==0;
                  return ListTile(
                    title: Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              message.content!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color:
                                isUser
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          // Input field and Send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.textController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.textController.text;
                    if (text.isNotEmpty) {
                      _controller.sendMessage(text);
                      _controller.textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
