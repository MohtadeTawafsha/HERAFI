import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:herafi/presentation/controllers/AuthController/homePageController.dart';

class itemInBottomNavigationBar extends StatelessWidget {
  const itemInBottomNavigationBar({
    super.key,
    required this.icon,
    required this.index,
    required this.onPressed, // Add onPressed parameter
  });

  final IconData icon;
  final int index;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final homePageController controller = Get.find();
    return Obx(() {
      return TextButton(
        onPressed: () {
          controller.selectItem(index);
          onPressed(); // Call the onPressed function
        },
        child: Column(
          mainAxisAlignment: controller.isSelected(index)
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: controller.index == index ? Colors.white : Colors.grey.shade400,
            ),
          ],
        ),
      );
    });
  }
}
