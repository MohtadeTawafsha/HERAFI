import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';

import '../../../domain/entites/job.dart';
import '../../../domain/usecases/Job/SearchJobsUseCase.dart';

class craftsmanSearchController extends GetxController {
  final SearchJobsUseCase searchJobsUseCase;

  craftsmanSearchController(this.searchJobsUseCase);

  final TextEditingController searchController = TextEditingController();
  final RxList<JobEntity> jobs = <JobEntity>[].obs;
  final RxBool isLoading = false.obs;
  final UserEntity userEntity=Get.find<crossData>().userEntity!;
  final ScrollController scrollController = ScrollController();
  int currentPage = 1;
  String lastQuery = '';
  bool isFinished=false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          lastQuery.isNotEmpty) {
        if(isFinished)return;
        fetchMoreJobs(lastQuery);
      }
    });
  }

  Future<void> searchJobs() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    lastQuery = query;
    currentPage = 1;
    jobs.clear();
    isLoading.value = true;
    print(query);
    final result = await searchJobsUseCase(query, currentPage,(userEntity as CraftsmanEntity).category);
    result.fold(
          (failure) => Get.snackbar('خطأ', 'فشل في البحث عن الوظائف'),
          (newJobs) => jobs.addAll(newJobs),
    );

    isLoading.value = false;
  }

  Future<void> fetchMoreJobs(String query) async {
    currentPage++;
    isLoading.value = true;

    final result = await searchJobsUseCase(query, currentPage,(userEntity as CraftsmanEntity).category);
    result.fold(
          (failure) => Get.snackbar('خطأ', 'فشل في تحميل المزيد من الوظائف'),
          (newJobs){
            isFinished=jobs.length<15;
            jobs.addAll(newJobs);
          }
    );

    isLoading.value = false;
  }
}
