import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/bindings/jobsBinding/createJobBinding.dart';
import 'package:herafi/presentation/controllers/AuthController/homePageController.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:herafi/presentation/pages/JobPages/createJobPage.dart';
import 'package:herafi/presentation/pages/account_screen.dart';
import 'package:herafi/presentation/pages/trakingPage.dart';
import '../../Widgets/itemInBottomNavigationBar.dart';
import '../../bindings/homeBinding/craftsmanHomeBinding.dart';
import 'homePageCraftsman.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});
  @override
  Widget build(BuildContext context){
    final crossData cross_Data=Get.find<crossData>();
    final homePageController controller = Get.find();
    print(cross_Data.userEntity.userType);
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: cross_Data.userEntity.isCraftsman()?bottomNavigationBarForCraftsman(controller):bottomNavigationBarForCustomer(controller),
        body: Obx(() {
          return getSelectedPage(controller);
        }),
    );
  }

  Widget getSelectedPage(homePageController controller) {
    if(Get.find<crossData>().userEntity.isCraftsman()){
      switch (controller.index.value) {
        case 4:
          return AccountScreen();
        case 3:return trackingPage();
        default:{
          craftsmanHomeBinding().dependencies();
          return craftsmanHomePage();
        }
      }
    }
    else{
      switch (controller.index.value) {
        case 4:
          return AccountScreen();
        case 3:return trackingPage();
        case 2:
          {
            createJobBinding().dependencies();
            return createJobPage();
          };
        default:
          return HomePage(controller);
      }
    }
  }
  Widget HomePage(homePageController controller){
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
  Widget bottomNavigationBarForCustomer(homePageController controller) {
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
              icon: Icons.home_outlined,
              index: 0,
            ),
            itemInBottomNavigationBar(
              icon: Icons.shopping_cart_outlined,
              index: 1,
            ),
            itemInBottomNavigationBar(
              icon: Icons.add,
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
  Widget bottomNavigationBarForCraftsman(homePageController controller) {
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
              icon: Icons.home_outlined,
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
