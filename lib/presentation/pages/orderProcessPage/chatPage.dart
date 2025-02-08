import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/presentation/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Widgets/leadingAppBar.dart';
import '../../controllers/crossDataContoller.dart';
import '../project/projectPage.dart';
import 'package:herafi/presentation/controllers/orderPageControllers/chatPageController.dart';
import 'package:herafi/presentation/Widgets/progressIndicator.dart';

class chatPage extends StatelessWidget {
  const chatPage({super.key});

  Future<void> handleProjectDetails(chatPageController controller) async {
    final SupabaseClient supabaseClient = Supabase.instance.client;

    try {
      Get.toNamed(AppRoutes.createProject,arguments: {
        "customer": Get.find<crossData>().userEntity,
        "craftsman": controller.chat.user,
      });
    } catch (error) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء معالجة تفاصيل المشروع: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final chatPageController controller = Get.find();
    final crossData data = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                controller.chat.user.getImage(),
              ),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 15),
            Text(controller.chat.user.name),
          ],
        ),
        leading: leadingAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if(data.userEntity!.isCustomer())
            ...[SizedBox(height: 10,),
              Container(
                color: Colors.grey.shade800,
                padding: EdgeInsets.symmetric(horizontal: 32,vertical: 12),
                child: TextButton(
                  onPressed: ()=>handleProjectDetails(controller),
                  child: Container(
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('انشاء مشروع',style:Theme.of(context).textTheme!.bodyLarge!.copyWith(color: Colors.black),),
                        ],
                      )),
                ),
              ),],
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !controller.isItNewChat) {
                  return progressIndicator();
                } else {
                  return Container(
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      reverse: true,
                      controller: controller.scrollController,
                      itemCount: controller.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index != controller.messages.length) {
                          final message = controller.messages[index];
                          return ListTile(
                            title: Align(
                              alignment: message.senderId == controller.currentUserId
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: message.senderId == controller.currentUserId
                                      ? Colors.blueAccent
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    if (message.resource != null)
                                      GestureDetector(
                                        child: Hero(
                                          tag: message.resource!,
                                          child: CachedNetworkImage(
                                            imageUrl: message.resource!,
                                            width: Get.width * 0.6,
                                          ),
                                        ),
                                        onTap: () {
                                          controller.handleImageTap(message.resource!);
                                        },
                                      ),
                                    Text(
                                      message.text,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: message.senderId == controller.currentUserId
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          if (controller.isFinishedFetchingMessages.value ||
                              controller.isItNewChat) {
                            return Container();
                          } else {
                            return Center(child: progressIndicator());
                          }
                        }
                      },
                    ),
                  );
                }
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: controller.sendImageMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: controller.sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
