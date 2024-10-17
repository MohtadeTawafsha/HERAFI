import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/AuthController/homePageController.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Widgets/itemInBottomNavigationBar.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});
  @override
  Widget build(BuildContext context) {
    final homePageController controller = Get.find();
    return Scaffold(
      key: controller.scaffoldKey,
      bottomNavigationBar: bottomNavigationBar(controller),
      body: Stack(
        children: [
          Center(
            child: Text('الصفحة الرئيسية'),
          )
        ],
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
                topRight: Radius.circular(15.spMin))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            itemInBottomNavigationBar(
              icon:
                Icons.home_outlined,
              index: 0,
            ),
            itemInBottomNavigationBar(
              icon: Icons.shopping_cart_outlined,
              index: 1,
            ),
            itemInBottomNavigationBar(
                icon: Icons.manage_search,
                index: 2,
                ),
            itemInBottomNavigationBar(
              icon: Icons.task,
              index: 3,
            ),
            itemInBottomNavigationBar(
              icon: Icons.person,
              index: 4,
            ),
          ],
        ),
      );
    });
  }
}
