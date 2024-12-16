import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/job.dart';
import 'package:herafi/global/alers.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/usecases/Job/createJobUseCase.dart';
import '../../../global/constants.dart';
import '../../../global/setOfMethods.dart';
import '../../routes/app_routes.dart';

class createJobController extends GetxController{
  final createJobUseCase createJob;

  createJobController({required this.createJob});
  final currentStep = 0.obs;
  final firstStepKey=GlobalKey<FormState>();
  final thirdStepKey=GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final mapPointController = TextEditingController();
  RxList<double> location = <double>[].obs;
  final Rx<bool> visiableToAllTypes=false.obs;

  final selectedService = ''.obs;
  final selectedImagePath = ''.obs;
  final selectedCity = ''.obs;

  void nextStep() {
    if(currentStep==1 && selectedImagePath.isEmpty){
      Get.snackbar("خطأ", "يجب اضافة صورة");
      return;
    }
    if((currentStep==0 && firstStepKey.currentState!.validate()) || currentStep==1) {
      if (currentStep.value < 2) {
        currentStep.value++;
      } else {
        submitJob();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void setImagePath(String path) {
    selectedImagePath.value = path;
  }

  void addLocationOnMap() {
    // Call your map logic here
    Get.snackbar('خريطة', 'تم فتح الخريطة لإضافة الموقع.');
  }

  void submitJob()async{
    globalMethods().showProgressDialog();
    if (firstStepKey.currentState!.validate() && selectedImagePath.isNotEmpty && thirdStepKey.currentState!.validate()){
      final result=await createJob(JobEntity(id: 0, city: selectedCity.value, description: descriptionController.text, createdAt: DateTime.now(), status: 'define', title: titleController.text, image: selectedImagePath.value, mapLatitude: location[0].toString(), mapLongitude: location[0].toString(), categoryName: selectedService.value, visibilityAllTypes: visiableToAllTypes.value));
      Get.back();
      result.fold(
              (ifLeft){
                alerts().showErrorSnackBar(Get.context!, 'لقد حدث خطأ, يرجى المحاولة مرة اخرى');
              }, (ifRight){
        resetInputs();
        alerts().showSuccessSnackBar(Get.context!, 'لقد تم اضافة الوظيفة بنجاح');
      });
    }
    else{
      Get.back();
      Get.snackbar('خطأ', 'يجب تعبأت جميع الحقول');
    }
    // Perform job submission logic
  }
  void resetInputs() {
    // Reset form state
    firstStepKey.currentState?.reset();
    thirdStepKey.currentState?.reset();

    // Reset controllers
    titleController.clear();
    descriptionController.clear();
    mapPointController.clear();

    // Reset reactive variables
    currentStep.value = 0;
    selectedService.value = '';
    selectedImagePath.value = '';
    selectedCity.value = '';
    location.clear();
    visiableToAllTypes.value = false;
  }
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  void goToStep(int step) {
    if(currentStep.value==step)return;
    if(currentStep>step){
      currentStep.value=step;
      return;
    }
    if(step==2){
      if(currentStep==0) {
        nextStep();
      }
      nextStep();
    }
    else if(step==1){
      nextStep();
    }

  }
  void handleBottomButton(){
    if(currentStep==2){
submitJob();
    }
    else{
      nextStep();
    }
  }
  void handleEditPointOnMap() async {
    var x = await Get.toNamed(AppRoutes.selectPointOnMap,
        arguments: location.isEmpty
            ? constants.mapInitialLocation
            : LatLng(location[0], location[1]));
    if (x == null) return;
    location.value = [x.latitude, x.longitude];
    mapPointController.text="long=${x.longitude.toString().substring(0,5)} lat=${x.latitude.toString().substring(0,5)}";
  }
}