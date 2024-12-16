import 'package:get/get.dart';
import 'package:herafi/data/repositroies/jobRepositoryImp.dart';

import '../../../domain/usecases/Job/SearchJobsUseCase.dart';
import '../../controllers/jobsControllers/craftsmanSearchController.dart';

class craftsmanSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SearchJobsUseCase(JobRepositoryImpl()));
    Get.lazyPut(() => craftsmanSearchController(Get.find<SearchJobsUseCase>()));
  }
}
