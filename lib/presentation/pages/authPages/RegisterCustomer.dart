import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/remotDataSource/customerDataSource.dart';
import '../../../domain/entites/user.dart';
import '../../../global/constants.dart';
import '../../Widgets/progressIndicator.dart';
import '../../controllers/crossDataContoller.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({Key? key}) : super(key: key);

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCity;


  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient supabaseClient = Supabase.instance.client;



  Future<void> _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      try {
        Get.dialog(
          Center(child: progressIndicator()),
          barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
        );

        final String name = _nameController.text.trim();
        final String dob = _dobController.text.trim();



        final CustomerRemoteDataSource dataSource = CustomerRemoteDataSource(
          supabaseClient,
          firebaseAuth,
        );

        await dataSource.saveCustomerDetails(
          name: name,
          location: _selectedCity!,
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
          dateOfBirth: DateTime.parse(dob), // Pass DOB

        );

        Get.find<crossData>().userEntity = UserEntity(
          name: name,
          id: FirebaseAuth.instance.currentUser!.uid,
          image: '',
          createdAt: DateTime.now(),
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
          userType: "customer",
          location: _selectedCity!,
          dateOfBirth: DateTime.parse(dob),
        );

        Get.offAllNamed('/home'); // Navigate to home after success
      } catch (e) {
        Get.snackbar('Error', 'An error occurred: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل حساب العميل'),
          leading: leadingAppBar(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16),
              children: [
                SizedBox(height: 16,),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16,),
                // Date of Birth Field
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                        "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال تاريخ الميلاد';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16,),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, // Label color
                    ),
                    border: InputBorder.none, // Remove the default border
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                  ),
                  dropdownColor: Theme.of(context).focusColor,
                  value: _selectedCity,
                  items: constants.palestinianCities.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category,style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color:_selectedCity==category?Colors.white: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الموقع';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16,),

                // Register Button
                TextButton(
                  onPressed: _registerCustomer,
                  child: const Text('تسجيل'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}