import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Widgets/leadingAppBar.dart';
import '../project/projectPage.dart';
import 'package:herafi/presentation/controllers/orderPageControllers/chatPageController.dart';
import 'package:herafi/presentation/Widgets/progressIndicator.dart';

class chatPage extends StatelessWidget {
  const chatPage({super.key});

  Future<void> handleProjectDetails(chatPageController controller) async {
    final SupabaseClient supabaseClient = Supabase.instance.client;

    try {
      // جلب بيانات المستخدم الحالي
      final currentUserId = controller.currentUserId;

      // تحديد الطرف الآخر في المحادثة
      final otherUser = controller.chat.user;

      // تحديد العميل والحرفي بناءً على نوع المستخدم
      final String customerId =
      otherUser.userType == 'customer' ? otherUser.id : currentUserId;
      final String craftsmanId =
      otherUser.userType == 'craftsman' ? otherUser.id : currentUserId;

      // التحقق من وجود المشروع بالفعل مع تحديد نتيجة واحدة
      final existingProject = await supabaseClient
          .from('projects')
          .select('id')
          .eq('customer_id', customerId)
          .eq('craftsman_id', craftsmanId)
          .limit(1) // تحديد صف واحد فقط
          .maybeSingle();

      if (existingProject != null) {
        // إذا كان المشروع موجودًا، الانتقال مباشرة إلى صفحة ProjectPage
        Get.to(() => ProjectPage(
          customerId: customerId,
          craftsmanId: craftsmanId,
        ));
        return;
      }

      // إذا لم يكن المشروع موجودًا، إضافته
      await supabaseClient.from('projects').insert({
        'customer_id': customerId,
        'craftsman_id': craftsmanId,
      });

      // فتح صفحة ProjectPage
      Get.to(() => ProjectPage(
        customerId: customerId,
        craftsmanId: craftsmanId,
      ));
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
            // زر تفاصيل المشروع
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تفاصيل المشروع:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleProjectDetails(controller);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('تفاصيل المشروع'),
                  ),
                ],
              ),
            ),
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
