import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';

import '../../../domain/entites/craftsman.dart';
import '../../../domain/entites/job.dart';
import '../../../domain/usecases/Job/FetchJobsUseCase.dart';

class craftsmanHomeController extends GetxController{
  final FetchJobsUseCase fetchJobsUseCase;

  craftsmanHomeController(this.fetchJobsUseCase);

  final RxList<JobEntity> jobs = <JobEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<int> showMoreIndices = <int>{}.obs;

  String craftsmanName = 'اسم الحرفي';
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchInitialJobs();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent &&
          !isLoading.value) {
        fetchMoreJobs();
      }
    });
  }

  Future<void> fetchInitialJobs() async {
    isLoading.value = true;
    String category=((Get.find<crossData>().userEntity) as CraftsmanEntity).category;
    final result = await fetchJobsUseCase(currentPage,category);
    result.fold(
          (failure) => Get.snackbar('خطأ', 'فشل في جلب الوظائف'),
          (newJobs) => jobs.addAll(newJobs),
    );
    isLoading.value = false;
  }

  Future<void> fetchMoreJobs() async {
    currentPage++;
    await fetchInitialJobs();
  }

  void toggleShowMore(int index) {
    if (showMoreIndices.contains(index)) {
      showMoreIndices.remove(index);
    } else {
      showMoreIndices.add(index);
    }
  }
}