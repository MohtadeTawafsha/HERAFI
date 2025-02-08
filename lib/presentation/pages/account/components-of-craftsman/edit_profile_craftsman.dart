import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:herafi/data/remotDataSource/craftsmanRemotDataSource.dart';
import 'package:herafi/data/repositroies/craftsmanRepositoryImp.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/global/constants.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../domain/entites/user.dart';

class EditCraftsmanScreen extends StatefulWidget {
  @override
  _EditCraftsmanScreenState createState() => _EditCraftsmanScreenState();
}

class _EditCraftsmanScreenState extends State<EditCraftsmanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: (Get.find<crossData>().userEntity as CraftsmanEntity).name);
  final _locationController = TextEditingController(text: (Get.find<crossData>().userEntity as CraftsmanEntity).location);
  final _yearsOfExperienceController = TextEditingController(text: (Get.find<crossData>().userEntity as CraftsmanEntity).yearsOfExp.toString());
  final _categoryController = TextEditingController(text: (Get.find<crossData>().userEntity as CraftsmanEntity).category);
  String _imageUrl=(Get.find<crossData>().userEntity as CraftsmanEntity).image;
  bool _isLoading=false;


  @override
  void initState() {
    super.initState();
  }


  Future<void> _updateCraftsmanProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final craftsmanId = FirebaseAuth.instance.currentUser?.uid;
      if (craftsmanId == null) throw Exception("المستخدم غير مسجل الدخول");

      final repository = CraftsmanRepositoryImpl(CraftsmanRemoteDataSource(
        Supabase.instance.client,
        FirebaseAuth.instance,
      ));

      final fetchedResult = await repository.fetchCraftsmanById(craftsmanId);
      CraftsmanEntity? fetchedCraftsman;
      fetchedResult.fold(
            (failure) => throw Exception(failure.message),
            (craftsman) => fetchedCraftsman = craftsman,
      );

      if (fetchedCraftsman == null) {
        throw Exception("فشل في جلب بيانات الحرفي");
      }

      final craftsman = CraftsmanEntity(
        id: craftsmanId,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        yearsOfExp: int.parse(_yearsOfExperienceController.text.trim()),
        category: _categoryController.text.trim(),
        image: _imageUrl ?? '',
        createdAt: fetchedCraftsman!.createdAt,
        phoneNumber: fetchedCraftsman?.phoneNumber ?? 'رقم غير متوفر',
        userType: fetchedCraftsman!.userType,
        dateOfBirth: fetchedCraftsman?.dateOfBirth ?? DateTime(2000, 1, 1),

      );

      final result = await repository.updateCraftsman(craftsman);
      result.fold(
            (failure) => throw Exception(failure.message),
            (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح")),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تحديث الملف الشخصي: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تعديل معلومات الحرفي"),
        leading: leadingAppBar(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _uploadImageToFirebase(File(pickedFile.path));
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  child: _imageUrl == null ? Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "الاسم"),
                validator: (value) =>
                value == null || value.isEmpty ? "يرجى إدخال الاسم" : null,
              ),
              SizedBox(height: 10),
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
                value: _locationController.text.isNotEmpty ? _locationController.text : null,
                items: constants.palestinianCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city,style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color:_locationController.text==city?Colors.white: Colors.black),),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _locationController.text = newValue;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار الموقع';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final currentValue = int.tryParse(_yearsOfExperienceController.text) ?? 0;
                      if (currentValue > 0) {
                        _yearsOfExperienceController.text = (currentValue - 1).toString();
                      }
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _yearsOfExperienceController,
                      decoration: const InputDecoration(
                        labelText: 'سنوات الخبرة',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "يرجى إدخال سنوات الخبرة";
                        }
                        final years = int.tryParse(value);
                        if (years == null || years < 0 || years > 60) {
                          return "يرجى إدخال رقم صحيح بين 0 و60";
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final currentValue = int.tryParse(_yearsOfExperienceController.text) ?? 0;
                      if (currentValue < 60) {
                        _yearsOfExperienceController.text = (currentValue + 1).toString();
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'التخصص',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white, // Label color
                  ),
                  border: InputBorder.none, // Remove the default border
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding
                ),
                dropdownColor: Theme.of(context).focusColor,
                value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                items: constants.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category,style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color:_categoryController.text==category?Colors.white: Colors.black),),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _categoryController.text = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار التخصص';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              TextButton(
                onPressed: _updateCraftsmanProfile,
                child: Text("حفظ التغييرات"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _yearsOfExperienceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<String> _uploadImageToFirebase(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('craftsman_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });

      return imageUrl;
    } catch (e) {
      throw Exception("فشل في تحميل الصورة: $e");
    }
  }
}
