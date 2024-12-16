import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/global/constants.dart';
import 'package:herafi/global/setOfMethods.dart';
import 'package:herafi/global/validator.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:herafi/presentation/controllers/jobsControllers/createJopController.dart';

import '../../../domain/entites/customer.dart';

class createJobPage extends StatelessWidget {
  const createJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    final createJobController controller=Get.find<createJobController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة وظيفة'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return Stepper(
              onStepTapped: (int step) {
                controller.goToStep(step); // Allow user to tap and move to a specific step
              },
              currentStep: controller.currentStep.value,
              onStepContinue: controller.nextStep,
              onStepCancel: controller.previousStep,
              steps: [
                // Step 1: Add Job Title, Description, and Service
                Step(
                  title: Text('تفاصيل الوظيفة'),
                  content: Form(
                    key: controller.firstStepKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: Validator().notEmpty,
                          controller: controller.titleController,
                          decoration: InputDecoration(labelText: 'عنوان الوظيفة'),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: Validator().notEmpty,
                          controller: controller.descriptionController,
                          decoration: InputDecoration(labelText: 'وصف الوظيفة'),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          validator: Validator().notEmpty,
                          value: controller.selectedService.value.isEmpty
                              ? null
                              : controller.selectedService.value,
                          decoration: InputDecoration(labelText: 'الخدمة'),
                          items: constants.categories
                              .map((service) =>
                              DropdownMenuItem(value: service, child: Text(service)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedService.value = value;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('السماح للقطاعات الاخرى برؤية الوظيفة'),
                            Checkbox(value: controller.visiableToAllTypes.value, onChanged: (v)=>controller.visiableToAllTypes.value=v!)
                          ],
                        )
                      ],
                    ),
                  ),
                  isActive: controller.currentStep.value >= 0,
                ),
                // Step 2: Add Job Image
                Step(
                  title: Text('إضافة صورة'),
                  content: Column(
                    children: [
                      controller.selectedImagePath.isNotEmpty
                          ? Image.file(
                        File(controller.selectedImagePath.value),
                        height: 100,
                      )
                          : GestureDetector(
                        onTap: () async {
                          final imagePath =
                          await globalMethods().selectPhoto(context:context, width: 1000, height: 1000);
                          if (imagePath != null) {
                            controller.setImagePath(imagePath);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.grey.shade600,),
                          width: 100,
                          height: 100,
                          child: Icon(Icons.add),
                        ),
          
                      ),
          
                    ],
                  ),
                  isActive: controller.currentStep.value >= 1,
                ),
                // Step 3: Add City and Location
                Step(
                  title: Text('إضافة موقع'),
                  content: Form(
                    key: controller.thirdStepKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            validator: Validator().notEmpty,
                            value: controller.selectedCity.value.isEmpty
                                ? null
                                : controller.selectedCity.value,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white, // Text color (adjust for contrast)
                            ),
                            decoration: InputDecoration(
                              labelText: 'المدينة',
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white, // Label color
                              ),
                              border: InputBorder.none, // Remove the default border
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                            ),
                            dropdownColor: Theme.of(context).focusColor, // Set dropdown menu background color
                            items: constants.palestinianCities
                                .map(
                                  (city) => DropdownMenuItem(
                                value: city,
                                child: Text(
                                  city,
                                  style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color:city==controller.selectedCity.value?Colors.white: Colors.black),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedCity.value = value;
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 10),
                        TextFormField(
                          validator: Validator().notEmpty,
                          controller: controller.mapPointController,
                          decoration: InputDecoration(
                            labelText: 'حقل النص',
                            hintText: 'اضغط لتعبئة البيانات',
                            suffixIcon: Icon(Icons.edit,color: Colors.white,),
                          ),
                          readOnly: false,
                          onTap: controller.handleEditPointOnMap,

                        )
                      ],
                    ),
                  ),
                  isActive: controller.currentStep.value >= 2,
                ),
              ],
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return   Container();
              },
            );
          }),
          Column(
            children: [
              Obx((){
                return TextButton(onPressed:controller.handleBottomButton, child: Text(controller.currentStep.value==2?'اضافة مشكلة':"التالي"));
              }),
              SizedBox(height: 30,)
            ],
          )
        ],
      ),
    );
  }
}
