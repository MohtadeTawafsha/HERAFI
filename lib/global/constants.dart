import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
class constants {
  static String appName = "حرفي";
  static LatLng mapInitialLocation = LatLng(32.06502, 35.02554);
  static final List<String> categories = [
    'السباكة',
    'النجارة',
    'الكهرباء',
    'الطلاء',
    'البناء',
    'الزراعة',
    'الميكانيك',
    'الحدادة',
    'التكييف والتبريد',
    'النقل',
    'الخياطة',
    'التعليم الخصوصي',
    'الصيانة المنزلية',
    'التجميل',
    'تنظيف المنازل',
    'تصليح الأجهزة الإلكترونية',
    'الطباعة والتغليف',
    'تصميم الديكور',
    'الإصلاحات العامة',
    'الطهي والتموين',
    'النجدة والطوارئ',
    'الاستشارات الهندسية',
    'الاستشارات القانونية',
    'التصوير',
  ];
  static List<String> palestinianCities = [
    // الضفة الغربية
    "رام الله",
    "نابلس",
    "الخليل",
    "بيت لحم",
    "جنين",
    "طولكرم",
    "قلقيلية",
    "سلفيت",
    "أريحا",
    "طوباس",

    // قطاع غزة
    "غزة",
    "رفح",
    "خان يونس",
    "دير البلح",
    "بيت حانون",
    "بيت لاهيا",

    // القدس الشرقية
    "القدس",

    // المدن المحتلة (أراضي 1948)
    "حيفا",
    "يافا",
    "عكا",
    "الناصرة",
    "اللد",
    "الرملة",
    "صفد",
    "طبريا",
    "بئر السبع",
    "بيسان",
    "الناصرة",
    "الرلمة",
  ];
  static Widget marker = GestureDetector(
      child: Icon(
        Icons.location_on_outlined,
        color: Colors.green,
        size: 40.spMin,
      ));

}
