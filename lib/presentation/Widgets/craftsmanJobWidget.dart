import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/domain/entites/Message.dart';
import 'package:herafi/domain/entites/job.dart';
import 'package:herafi/presentation/Widgets/showImage.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:herafi/presentation/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entites/chat.dart';
import '../pages/account/components-of-customer/customer_profile_page.dart';


class craftsmanJobWidget extends StatefulWidget {
  const craftsmanJobWidget({super.key, required this.job});
  final JobEntity job;

  @override
  State<craftsmanJobWidget> createState() => _craftsmanJobWidgetState();
}

class _craftsmanJobWidgetState extends State<craftsmanJobWidget> {
  bool showMore=false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (c)=>CustomerProfilePage(customerId: widget.job.customer.id))),
            title: Text(widget.job.customer.name),
            subtitle: Text(widget.job.getDateFormat()+" - "+widget.job.city,style: TextStyle(color: Colors.grey),),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.job.customer.getImage()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.job.title,style: Theme.of(context).textTheme!.bodyLarge,),
              Text(
                widget.job.description,
                maxLines: showMore ? null : 3,
                overflow: showMore
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,style: Theme.of(context).textTheme!.bodySmall,
              ),
              if (widget.job.description.length > 100)
                Theme(
                  data: ThemeData(),
                  child: TextButton(
                    onPressed:toggleShowMore,
                    child: Text(showMore
                        ? 'عرض أقل'
                        : 'عرض المزيد',style: Theme.of(context).textTheme!.bodySmall,),
                  ),
                ),
              GestureDetector(child: Container(width:double.infinity,child: CachedNetworkImage(imageUrl: widget.job.image,fit: BoxFit.fitWidth,)),onTap: (){handleImageTap(widget.job.image);},),
              SizedBox(height: 10,),
              Divider(color: Colors.grey.withOpacity(0.2),),
            ],
          ),
          Theme(
            data: ThemeData(),
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: handleAddressAction,
                      child: Container(
                        height: 50,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on_outlined,color: Colors.grey.shade400,),
                            SizedBox(width: 10,),
                            Text('الموقع',style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color: Colors.grey.shade400,),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: handleContactAction,
                      child: Container(
                        height: 40,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message,color: Colors.grey.shade400,),
                            SizedBox(width: 10,),
                            Text('تواصل',style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color: Colors.grey.shade400,),)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void handleContactAction(){
    List<chatEntity> chats=Get.find<crossData>().chats;
    chatEntity chat=chatEntity(user: widget.job.customer, lastMessage:null, missedMessagesCountByMe: 0, missedMessagesCountByOther: 0, documentId: '');
    chats.forEach((item){
      if(item.user.id==widget.job.customer.id){
        chat=item;
      }
    });
    Get.toNamed(AppRoutes.chatpage,arguments: chat);
  }
  void handleAddressAction(){
    Get.toNamed(AppRoutes.ShowPointOnMap,arguments: widget.job.getLocationPoint());
  }
  void toggleShowMore() {
    setState(() {
      showMore=!showMore;
    });
  }

  void handleImageTap(String imageSource){
    Get.to(imageViewWithInteractiveView(title: 'صورة', image: imageSource,));
  }
}
