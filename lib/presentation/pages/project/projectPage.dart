import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/global/validator.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:herafi/presentation/Widgets/progressIndicator.dart';

import '../../controllers/projects/createProject.dart';

class CreateProject extends StatelessWidget {
  const CreateProject({super.key});

  @override
  Widget build(BuildContext context) {
    final createProjectController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('انشاء مشروع'),
        leading: leadingAppBar(),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستفيد'),
            userWidget(controller.customer),
            SizedBox(
              height: 6,
            ),
            Text("الحرفي"),
            userWidget(controller.craftsman),
            SizedBox(
              height: 6,
            ),
            projectDetails(controller),
            SizedBox(
              height: 6,
            ),
            lunchButton(controller)
          ],
        ),
      ),
    );
  }
  Widget userWidget(UserEntity user) {
    return ListTileTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        tileColor: Colors.grey.withOpacity(0.3),
        leading: CircleAvatar(
          radius: 50,
          backgroundImage: CachedNetworkImageProvider(user.getImage()),
        ),
        title: Text(
          user.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          user.phoneNumber,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
  Widget projectDetails(createProjectController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تفاصيل المشروع'),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10)),
          width: double.infinity,
          child: Form(
            key: controller.key,
            child: Column(
              spacing: 20,
              children: [
                SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عنوان المشروع'),
                    TextFormField(
                      style: TextStyle(fontSize: 15),
                      validator: Validator().notEmpty,
                      controller: controller.title,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 0),
                          fillColor: Colors.grey,
                          constraints:
                              BoxConstraints(maxHeight: 40, maxWidth: 150),
                          contentPadding: EdgeInsets.all(5),
                          filled: true,
                          label: Text('العنوان'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('السعر'),
                    TextFormField(
                      style: TextStyle(fontSize: 15),
                      validator: Validator().notEmpty,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                              r'^\d*\.?\d*'), // Allows digits and at most one decimal point
                        ),
                      ],
                      controller: controller.price,
                      decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 0),
                          fillColor: Colors.grey,
                          constraints:
                              BoxConstraints(maxHeight: 40, maxWidth: 150),
                          contentPadding: EdgeInsets.all(5),
                          filled: true,
                          label: Text('السعر'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تاريخ بداية العمل'),
                    TextFormField(
                      style: TextStyle(fontSize: 15),
                      validator: Validator().notEmpty,
                      controller: controller.startDate,
                      readOnly: true,
                      onTap: () => datePicker(controller.startDate),
                      decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 0),
                          fillColor: Colors.grey,
                          constraints:
                              BoxConstraints(maxHeight: 40, maxWidth: 150),
                          contentPadding: EdgeInsets.all(5),
                          filled: true,
                          label: Text('التاريخ'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تاريخ نهاية العمل'),
                    TextFormField(
                      style: TextStyle(fontSize: 15),
                      validator: Validator().notEmpty,
                      controller: controller.endDate,
                      readOnly: true,
                      onTap: () => datePicker(controller.endDate),
                      decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 0),
                          fillColor: Colors.grey,
                          constraints:
                              BoxConstraints(maxHeight: 40, maxWidth: 150),
                          contentPadding: EdgeInsets.all(5),
                          filled: true,
                          label: Text('التاريخ'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                    )
                  ],
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        )
      ],
    );
  }
  void datePicker(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );
    if (pickedDate == null) return;
    controller.text = pickedDate!.toLocal().toString().split(' ')[0];
  }
  Widget lunchButton(createProjectController controller){
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () {
          return TextButton(
            onPressed: controller.handleCreateProject,
            child: controller.isButtonLoading.value?progressIndicator(indicatorColor: Colors.black,):Text('انشاء'),
          );
        }
      ),
    );
  }

}
