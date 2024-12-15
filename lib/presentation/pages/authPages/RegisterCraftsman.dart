import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/remotDataSource/craftsmanRemotDataSource.dart';
import '../../../global/constants.dart';
import '../../Widgets/progressIndicator.dart';

class RegisterCraftsman extends StatefulWidget {
  const RegisterCraftsman({Key? key}) : super(key: key);

  @override
  State<RegisterCraftsman> createState() => _RegisterCraftsmanState();
}

class _RegisterCraftsmanState extends State<RegisterCraftsman> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dobController = TextEditingController(); // For Date of Birth
  String? _selectedCategory;
  String? _selectedCity;
  int _yearsOfExperience = 0;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient supabaseClient = Supabase.instance.client;

  void _incrementExperience() {
    setState(() {
      if (_yearsOfExperience < 60) {
        _yearsOfExperience++;
      }
    });
  }

  void _decrementExperience() {
    setState(() {
      if (_yearsOfExperience > 0) {
        _yearsOfExperience--;
      }
    });
  }

  Future<void> _registerCraftsman() async {
    if (_formKey.currentState!.validate()) {
      try {
        Get.dialog(
          Center(
            child: progressIndicator(),
          ),
          barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
        );
        final String name = _nameController.text.trim();
        final String location = _locationController.text.trim();
        final String dob = _dobController.text.trim();

        final CraftsmanRemoteDataSource dataSource = CraftsmanRemoteDataSource(
          supabaseClient,
          firebaseAuth,
        );

        await dataSource.saveCraftsmanDetails(
          category: _selectedCategory!,
          yearsOfExperience: _yearsOfExperience,
          name: name,
          location: location,
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!,
          dateOfBirth: DateTime.parse(dob), // Pass DOB
        );
        Get.find<crossData>().userEntity=UserEntity(name: name, id: FirebaseAuth.instance.currentUser!.uid, image: '', createdAt: DateTime.now(), phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber!, userType: "craftsman", location: location, dateOfBirth: DateTime.parse(dob));
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
          title: const Text('تسجيل حساب الحرفي'),
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
                        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
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

                const SizedBox(height: 10),

                // Years of Experience Field
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementExperience,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'سنوات الخبرة',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        controller: TextEditingController(
                          text: _yearsOfExperience.toString(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementExperience,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'التخصص'),
                  value: _selectedCategory,
                  items: constants.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار التخصص';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: _registerCraftsman,
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
    _locationController.dispose();
    _dobController.dispose(); // Dispose the DOB controller
    super.dispose();
  }
}
