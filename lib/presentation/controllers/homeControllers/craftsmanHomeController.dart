import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:herafi/presentation/routes/app_routes.dart';

import '../../../domain/entites/craftsman.dart';
import '../../../domain/entites/job.dart';
import '../../../domain/usecases/Job/FetchJobsUseCase.dart';

class craftsmanHomeController extends GetxController{
  final FetchJobsUseCase fetchJobsUseCase;
  craftsmanHomeController(this.fetchJobsUseCase);
  final RxList<JobEntity> jobs = <JobEntity>[].obs;
  final RxBool isLoading = false.obs;
  UserEntity userEntity= Get.find<crossData>().userEntity!;
  final ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool isFinished=false;

  @override
  void onInit() {
    super.onInit();
    fetchInitialJobs();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent &&
          !isLoading.value) {
        if(isFinished)return;
        fetchMoreJobs();
      }
    });
  }

  Future<void> fetchInitialJobs() async {
    isLoading.value = true;
    String category=((Get.find<crossData>().userEntity) as CraftsmanEntity).category;
    print("category:"+category);
    final result = await fetchJobsUseCase(currentPage,category);
    result.fold(
          (failure) => Get.snackbar('خطأ', 'فشل في جلب الوظائف'),
          (newJobs){
            isFinished=newJobs.length<15;
            jobs.addAll(newJobs);
          }
    );
    isLoading.value = false;
  }

  Future<void> fetchMoreJobs() async {
    currentPage++;
    await fetchInitialJobs();
  }
  void goToSearchPage(){
    Get.toNamed(AppRoutes.CraftsmanSearchPage);
  }
}