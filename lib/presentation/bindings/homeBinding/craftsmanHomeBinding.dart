import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/homeControllers/craftsmanHomeController.dart';

import '../../../data/repositroies/jobRepositoryImp.dart';
import '../../../domain/usecases/Job/FetchJobsUseCase.dart';

class craftsmanHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>JobRepositoryImpl());
    Get.lazyPut(()=>FetchJobsUseCase(Get.find<JobRepositoryImpl>()));
    Get.lazyPut(() => craftsmanHomeController(Get.find<FetchJobsUseCase>()));
  }
}
