import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/homeControllers/craftsmanHomeController.dart';

class craftsmanHomePage extends StatelessWidget {
  const craftsmanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<craftsmanHomeController>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.craftsmanName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality will be handled later
            },
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
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(job.title),
                    subtitle: Text(job.city),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(job.image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      job.description,
                      maxLines: controller.showMoreIndices.contains(index) ? null : 3,
                      overflow: controller.showMoreIndices.contains(index)
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.description.length > 100)
                    TextButton(
                      onPressed: () => controller.toggleShowMore(index),
                      child: Text(controller.showMoreIndices.contains(index)
                          ? 'عرض أقل'
                          : 'عرض المزيد'),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle Offer
                        },
                        child: const Text('عرض'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Address
                        },
                        child: const Text('العنوان'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
