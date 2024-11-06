import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/progressIndicator.dart';
import '../../Widgets/leadingAppBar.dart';
import '../../controllers/ChatbotController.dart';

class ChatbotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatbotController _controller = Get.find<ChatbotController>();


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(
                'lib/core/utils/images/robot-setting.png',
              ),
              backgroundColor: Theme.of(context).focusColor,
            ),
            SizedBox(width: 15,),
            Text('مساعد الحرفيين')
          ],
        ),
        leading: leadingAppBar(),
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.explore,color: Theme.of(context).focusColor,))],

      ),
      body: Column(
        children: [
          // Display chat messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: _controller.chatMessages.length+1,
                itemBuilder: (context, index) {
                  if(index==_controller.chatMessages.length){
                    if(_controller.isLoading.value){
                      return ListTile(trailing: SizedBox(width:50,height:50,child: progressIndicator()),);
                    }
                    return Container();
                  }
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
