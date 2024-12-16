import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/craftsmanJobWidget.dart';
import 'package:herafi/presentation/controllers/homeControllers/craftsmanHomeController.dart';

class craftsmanHomePage extends StatelessWidget {
  const craftsmanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<craftsmanHomeController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('صفقات فنية'),
        actions: [
          IconButton(
            icon:  Hero(tag: "SearchIcon", child: Icon(Icons.search,color: Theme.of(context).hintColor,size: 25,)),
            onPressed: controller.goToSearchPage,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.jobs.length,
          itemBuilder: (context, index) {
            final job = controller.jobs[index];
            return craftsmanJobWidget(job: job,);
          },
        );
      }),
    );
  }
}
