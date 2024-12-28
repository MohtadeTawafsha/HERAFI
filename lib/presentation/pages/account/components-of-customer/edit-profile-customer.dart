import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herafi/data/remotDataSource/customerDataSource.dart';
import 'package:herafi/global/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditCustomerScreen extends StatefulWidget {
  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedCity;
  double? _latitude;
  double? _longitude;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خدمة تحديد الموقع غير مفعّلة.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم رفض صلاحيات تحديد الموقع.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض صلاحيات الموقع بشكل دائم.')),
        );
        return;
      }

      // الحصول على الموقع الحالي
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
  Future<void> _fetchCustomerDetails() async {
    setState(() => _isLoading = true);

    try {
      final customerId = FirebaseAuth.instance.currentUser?.uid;
      if (customerId == null) throw Exception("User not logged in");

      final dataSource = CustomerRemoteDataSource(Supabase.instance.client, FirebaseAuth.instance);
      final data = await dataSource.fetchCustomerDetails(customerId);

      if (data != null) {
        setState(() {
          _nameController.text = data['users']['name'] ?? '';
          _dobController.text = data['users']['date_of_birth'] ?? '';
          _selectedCity = data['users']['location'] ?? '';
          _imageUrl = data['users']['image'];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch customer details: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
        mapLatitude: _latitude?.toString(), // تمرير خط العرض
        mapLongitude: _longitude?.toString(), // تمرير خط الطول
        image: _imageUrl, // تحديث الصورة إذا كانت موجودة
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context); // Close screen after update
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
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
      throw Exception("Failed to upload image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Customer Info")),
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
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter name" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: "Date of Birth"),
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
                value == null || value.isEmpty ? "Enter date of birth" : null,
              ),
              SizedBox(height: 10),

              // Dropdown for City
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "City"),
                value: _selectedCity,
                items: constants.palestinianCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? "Select a city" : null,
              ),
              ElevatedButton(
                onPressed: _getLocation,
                child: const Text('تحديد الموقع'),
              ),
              SizedBox(height: 10),
              if (_latitude != null && _longitude != null)
                Text("الموقع: $_latitude, $_longitude"),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCustomerProfile,
                child: Text("Save Changes"),
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