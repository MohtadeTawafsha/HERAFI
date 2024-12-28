import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
  double? _latitude; // خط العرض
  double? _longitude; // خط الطول

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient supabaseClient = Supabase.instance.client;
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة تحديد الموقع غير مفعّلة.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض صلاحيات تحديد الموقع.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض صلاحيات الموقع بشكل دائم.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديد الموقع: $_latitude, $_longitude')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديد الموقع: $e')),
      );
    }
  }

  Future<void> _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      try {
        Get.dialog(
          Center(child: progressIndicator()),
          barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
        );

        final String name = _nameController.text.trim();
        final String dob = _dobController.text.trim();

        if (_latitude == null || _longitude == null) {
          Get.back();
          Get.snackbar('Error', 'يرجى تحديد الموقع قبل التسجيل.');
          return;
        }

        final CustomerRemoteDataSource dataSource = CustomerRemoteDataSource(
          supabaseClient,
          firebaseAuth,
        );

        await dataSource.saveCustomerDetails(
          name: name,
          location: _selectedCity!,
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
          dateOfBirth: DateTime.parse(dob), // Pass DOB
          mapLatitude: _latitude.toString(), // تخزين خط العرض
          mapLongitude: _longitude.toString(), // تخزين خط الطول
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
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Name Field
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

                // Location Field

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الموقع'),
                  value: _selectedCity,
                  items: constants.palestinianCities.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
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
                ElevatedButton(
                  onPressed: _getLocation,
                  child: const Text('تحديد الموقع'),
                ),


                const SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: _registerCustomer,
                  child: const Text('تسجيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
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