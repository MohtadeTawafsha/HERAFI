import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herafi/presentation/pages/CraftsmanListPage.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/availability-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/certificate-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/craftsman-profile-Page.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/work_Page.dart';
import 'package:herafi/presentation/pages/account/components-of-customer/customer_profile_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../states/RateCraftsmanScreen.dart';
import 'components-of-craftsman/edit_profile_craftsman.dart';
import 'components-of-customer/edit-profile-customer.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = '';
  String? _userType;
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;
      if (_userId == null) throw Exception("User not logged in");

      final response = await Supabase.instance.client
          .from('users')
          .select('name, user_type')
          .eq('id', _userId as Object)
          .single();

      if (response != null) {
        setState(() {
          _userName = response['name'] ?? 'Unknown User';
          _userType = response['user_type'];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch user data: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(_userName),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              if (_userType == 'craftsman') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCraftsmanScreen()),
                );
              } else if (_userType == 'customer') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCustomerScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("نوع الحساب غير معروف.")),
                );
              }
            },
          ),

          Divider(),
          if (_userType == 'craftsman') ...[
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Works'),
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
              title: Text('Certificates'),
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
              title: Text('Availability'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvailabilityScreen()),
                );
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              if (_userType == 'craftsman') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CraftsmanProfilePage(craftsmanId: _userId!),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerProfilePage(customerId: _userId!,),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Craftsmen List'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CraftsmanListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Raiting'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RateCraftsmanScreen(craftsmanId: "jA1t5UPThWRLKJZOs89irszOlYo1"!)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}