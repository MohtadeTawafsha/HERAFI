import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/AuthController/homePageController.dart';
import 'package:herafi/presentation/routes/app_routes.dart';
import '../Widgets/itemInBottomNavigationBar.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});
  @override
  Widget build(BuildContext context) {
    final homePageController controller = Get.find();
    return Scaffold(
      key: controller.scaffoldKey,
      bottomNavigationBar: bottomNavigationBar(controller),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            header(controller),
            Center(
              child: Text('الصفحة الرئيسية'),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomNavigationBar(homePageController controller) {
    return Builder(builder: (context) {
      return Container(
        height: 70.spMin,
        decoration: BoxDecoration(
          color: Theme.of(context).focusColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.spMin),
            topRight: Radius.circular(15.spMin),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            itemInBottomNavigationBar(
              icon: Icons.home_outlined,
              index: 0,
              onPressed: () {}, // Placeholder for other tabs
            ),
            itemInBottomNavigationBar(
              icon: Icons.shopping_cart_outlined,
              index: 1,
              onPressed: () {},
            ),
            itemInBottomNavigationBar(
              icon: Icons.manage_search,
              index: 2,
              onPressed: () {},
            ),
            itemInBottomNavigationBar(
              icon: Icons.task,
              index: 3,
              onPressed: () {},
            ),
            itemInBottomNavigationBar(
              icon: Icons.person,
              index: 4,
              onPressed: () {
                // Navigate to RegisterRole page when index 4 is clicked
                Get.toNamed(AppRoutes.registerRole);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget header(homePageController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Theme(
          data: ThemeData(),
          child: TextButton(
            onPressed: () {
              controller.toChats();
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(
                  Icons.message_outlined,
                  size: 25,
                  color: Colors.white,
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Obx(() {
                    return Text(
                      controller.chats.fold<int>(0, (sum, combine) {
                        return sum + combine.missedMessagesCountByMe;
                      }).toString(),
                      style: Theme.of(Get.context!).textTheme!.bodySmall!,
                    );
                  }),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Theme(
          data: ThemeData(),
          child: IconButton(
            onPressed: () {
              controller.toChatBot();
            },
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  child: Image.asset('lib/core/utils/images/robot-setting.png'),
                  radius: 25,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
