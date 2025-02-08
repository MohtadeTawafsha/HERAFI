import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/data/remotDataSource/customerDataSource.dart';
import 'package:herafi/global/constants.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:get/get.dart';

import '../../../../global/setOfMethods.dart';
class EditCustomerScreen extends StatefulWidget {
  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: Get.find<crossData>().userEntity!.name);
  final _dobController = TextEditingController(text: "${Get.find<crossData>().userEntity!.dateOfBirth.toLocal()}".split(' ')[0]);
  String _selectedCity=Get.find<crossData>().userEntity!.location;

  String _imageUrl=Get.find<crossData>().userEntity!.image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }


  Future<void> _updateCustomerProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customerId = FirebaseAuth.instance.currentUser?.uid;
      if (customerId == null) throw Exception("User not logged in");

      final dataSource = CustomerRemoteDataSource(Supabase.instance.client, FirebaseAuth.instance);

      await dataSource.updateCustomerDetails(
        id: customerId,
        name: _nameController.text.trim(),
        location: _selectedCity!,
        dateOfBirth: DateTime.parse(_dobController.text.trim()),
        image: _imageUrl,
      );
      Get.find<crossData>().userEntity!.name=_nameController.text.trim();
      Get.find<crossData>().userEntity!.location=_selectedCity;
      Get.find<crossData>().userEntity!.dateOfBirth=DateTime.parse(_dobController.text.trim());
      Get.find<crossData>().userEntity!.image=_imageUrl;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح")),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تحديث الملف الشخصي: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImageToFirebase(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('customer_images')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تعديل معلومات العميل"),leading: leadingAppBar(),),
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
                  try {
                    String? pickedFile = await globalMethods().selectPhoto(
                        context: context);
                    if (pickedFile != null) {
                      await _uploadImageToFirebase(File(pickedFile));
                    }
                  }
                catch(e){
                  print(e.toString());
                }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null,
                  child: _imageUrl.isEmpty ? CircleAvatar(child: Icon(Icons.add_a_photo, size: 50,color: Theme.of(context).focusColor,),backgroundColor: Colors.grey,radius: 50,) : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "الاسم"),
                validator: (value) =>
                value == null || value.isEmpty ? "أدخل الاسم" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: "تاريخ الميلاد"),
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
                validator: (value) =>
                value == null || value.isEmpty ? "أدخل تاريخ الميلاد" : null,
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
                value: _selectedCity,
                items: constants.palestinianCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city,style: Theme.of(context).textTheme!.bodyMedium!.copyWith(color:_selectedCity==city?Colors.white: Colors.black),),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCity = newValue!;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? "اختر مدينة" : null,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _updateCustomerProfile,
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
    _dobController.dispose();
    super.dispose();
  }
}
