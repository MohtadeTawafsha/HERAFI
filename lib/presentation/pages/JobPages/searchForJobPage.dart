import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';

import '../../Widgets/craftsmanJobWidget.dart';
import '../../controllers/jobsControllers/craftsmanSearchController.dart';

class craftsmanSearchPage extends StatelessWidget {
  const craftsmanSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final craftsmanSearchController controller = Get.find<craftsmanSearchController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('البحث عن صفقات'),
        leading: leadingAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'أدخل النص للبحث...',
                  suffixIcon: IconButton(
                    icon:  Hero(tag: "SearchIcon", child: Icon(Icons.search,color: Theme.of(context).hintColor,size: 25,)),
                    onPressed: () => controller.searchJobs(),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) => controller.searchJobs(),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.jobs.isEmpty) {
                  return Center(child: Text((controller.searchController.text.isEmpty)?"ابحث عن الوظيفة":"لا توجد نتائج"));
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
            ),
          ],
        ),
      ),
    );
  }
}
