import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/pages/CraftsmansearchPage.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/availability-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/certificate-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/craftsman-profile-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/work_Page.dart';
import 'package:herafi/presentation/pages/account/components-of-customer/customer_profile_page.dart';
import '../../../domain/entites/craftsman.dart';
import '../../controllers/crossDataContoller.dart';
import '../states/RateCraftsmanScreen.dart';
import 'components-of-craftsman/edit_profile_craftsman.dart';
import 'components-of-customer/edit-profile-customer.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final crossData data=Get.find<crossData>();
    return Scaffold(
      appBar: AppBar(
        title: Text("الملف الشخصي"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(data.userEntity!.name),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              if (data.userEntity is CraftsmanEntity) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCraftsmanScreen()),
                );
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCustomerScreen()),
                );
              }
            },
          ),
          Divider(),
          if (data.userEntity is CraftsmanEntity) ...[
          ListTile(
              leading: Icon(Icons.work),
              title: Text('الأعمال'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkPage()),
                );
              },
            ),
          ListTile(
              leading: Icon(Icons.school),
              title: Text('الشهادات'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CertificateScreen()),
                );
              },
            ),
          ListTile(
              leading: Icon(Icons.schedule),
              title: Text('التوفر'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvailabilityScreen()),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('ملف الحرفي'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              if (data.userEntity is CraftsmanEntity) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CraftsmanProfilePage(craftsmanId: data.userEntity!.id),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerProfilePage(customerId:data.userEntity!.id,),
                  ),
                );
              }
            },
          ),
          /*ListTile(
            leading: Icon(Icons.star),
            title: Text('التقييم'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RateCraftsmanScreen(craftsmanId: FirebaseAuth.instance.currentUser!.uid)),
              );
            },
          ),*/
        ],
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('تسجيل الخروج'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
    ]
    )
    );

  }
}