
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';

import '../../data/models/ProjectModel.dart';

class ProjectEntity {
  final int id;
  final String title;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final String customerId;
  final String craftsmanId;
  String state;
  bool isCustomerConfirm;
  bool isCraftsmanConfirm;
  bool isRatingHappen;

  ProjectEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.customerId,
    required this.craftsmanId,
    required this.state,
    required this.isCraftsmanConfirm,
    required this.isCustomerConfirm,
    required this.isRatingHappen,
  });
  ProjectModel toModel() {
    return ProjectModel(
      id: id,
      title: title,
      price: price,
      startDate: startDate,
      endDate: endDate,
      customerId: customerId,
      craftsmanId: craftsmanId,
      state: state,
      isCraftsmanConfirm: isCraftsmanConfirm,
      isCustomerConfirm: isCustomerConfirm,
      isRatingHappen: isRatingHappen
    );
  }
  String get getState {
    if(state=="بأنتظار الموافقة")
      {
        if(Get.find<crossData>().userEntity!.isCustomer() && isCustomerConfirm){
          return "بأنتظار موافقة الحرفي";
        }
        else if(Get.find<crossData>().userEntity!.isCustomer() && isCustomerConfirm){
          return "بأنتظار موافقة المستفيد";

        }
        else if(Get.find<crossData>().userEntity!.isCraftsman() && isCustomerConfirm) {
          return "بأنتظار موافقة الحرفي";
        }
        else{
          return "بأنتظار موافقة المستفيد";
        }
      }
   return state;
  }
  bool isReadyForWork(){
    return getState=="جاهز العمل";
  }
  bool isWorkActive(){
    return DateTime.now().compareTo(startDate)>=0;
  }
  bool isFinished(){
    return getState=="منتهي";
  }
  bool canReject(){
    return (state=="بأنتظار الموافقة");
  }
  bool isCanceled(){
    return (state=="تم الالغاء");
  }
  String getImageUrl(){
    if(state=="بأنتظار الموافقة")return "lib/core/utils/images/projectStatus/defining.png";
    if(isCanceled())return "lib/core/utils/images/projectStatus/defining.png";
    if(isReadyForWork())return "lib/core/utils/images/projectStatus/defining.png";
    if(state=="بأنتظار دفع الزبون")return "lib/core/utils/images/projectStatus/money.png";
    if(isFinished())return "lib/core/utils/images/projectStatus/finish.png";
    return "lib/core/utils/images/projectStatus/defining.png";
  }
}