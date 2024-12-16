import 'package:get/get.dart';
import 'package:herafi/data/repositroies/jobRepositoryImp.dart';
import 'package:herafi/presentation/controllers/jobsControllers/createJopController.dart';

import '../../../domain/usecases/Job/createJobUseCase.dart';


class createJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>JobRepositoryImpl());
    Get.lazyPut(()=>createJobUseCase(Get.find<JobRepositoryImpl>()));
    Get.lazyPut(()=>createJobController(createJob: Get.find<createJobUseCase>()));
  }
}
