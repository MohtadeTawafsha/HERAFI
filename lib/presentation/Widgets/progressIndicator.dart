import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class progressIndicator extends StatelessWidget {
  progressIndicator({super.key,this.indicatorColor});

  Color? indicatorColor;
  @override
  Widget build(BuildContext context) {
    if((Platform.isIOS || Platform.isMacOS))
      return Center(child: CupertinoActivityIndicator(color:indicatorColor==null? Theme.of(context).focusColor:indicatorColor,radius: 15.sp,));
    else {
      return Center(child: SizedBox(child: FittedBox(child: CircularProgressIndicator(color: indicatorColor==null?Theme.of(context).focusColor.withOpacity(0.7):indicatorColor)),width: 25.sp,height: 25.sp,));
    }

  }
}
