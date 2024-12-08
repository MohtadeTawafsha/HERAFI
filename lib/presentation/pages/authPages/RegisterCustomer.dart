import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/remotDataSource/customerDataSource.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({Key? key}) : super(key: key);

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _locationController = TextEditingController();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String name = _nameController.text.trim();
        final String phoneNumber = _phoneController.text.trim();
        final String location = _locationController.text.trim();
        final String dob = _dobController.text.trim();

        final CustomerRemoteDataSource dataSource = CustomerRemoteDataSource(
          supabaseClient,
          firebaseAuth,
        );

        await dataSource.saveCustomerDetails(
          name: name,
          location: location,
          phoneNumber: phoneNumber,
          dateOfBirth: DateTime.parse(dob), // Pass DOB
        );

        Get.snackbar('Success', 'Customer registered successfully!');
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

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
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
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'الموقع'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الموقع';
                    }
                    return null;
                  },
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
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
