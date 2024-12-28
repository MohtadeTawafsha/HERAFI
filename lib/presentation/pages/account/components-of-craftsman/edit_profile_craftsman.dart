import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herafi/data/remotDataSource/craftsmanRemotDataSource.dart';
import 'package:herafi/data/repositroies/craftsmanRepositoryImp.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EditCraftsmanScreen extends StatefulWidget {
  @override
  _EditCraftsmanScreenState createState() => _EditCraftsmanScreenState();
}

class _EditCraftsmanScreenState extends State<EditCraftsmanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _categoryController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCraftsmanDetails();
  }
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
  Future<void> _fetchCraftsmanDetails() async {
    setState(() => _isLoading = true);
    try {
      final craftsmanId = FirebaseAuth.instance.currentUser?.uid;
      if (craftsmanId == null) throw Exception("User not logged in");

      final repository = CraftsmanRepositoryImpl(CraftsmanRemoteDataSource(
        Supabase.instance.client,
        FirebaseAuth.instance,
      ));

      final result = await repository.fetchCraftsmanById(craftsmanId);
      result.fold(
            (failure) => throw Exception(failure.message),
            (fetchedCraftsman) {
          _nameController.text = fetchedCraftsman.name;
          _locationController.text = fetchedCraftsman.location;
          _yearsOfExperienceController.text = fetchedCraftsman.yearsOfExp.toString();
          _categoryController.text = fetchedCraftsman.category;
          _imageUrl = fetchedCraftsman.image;

          // تحديث خطوط الطول والعرض
          _latitude = fetchedCraftsman.mapLatitude != null
              ? double.tryParse(fetchedCraftsman.mapLatitude!)
              : null;
          _longitude = fetchedCraftsman.mapLongitude != null
              ? double.tryParse(fetchedCraftsman.mapLongitude!)
              : null;

          setState(() {});
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch craftsman details: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCraftsmanProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final craftsmanId = FirebaseAuth.instance.currentUser?.uid;
      if (craftsmanId == null) throw Exception("User not logged in");

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
        throw Exception("Failed to fetch craftsman details");
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
        mapLatitude: _latitude?.toString() ?? fetchedCraftsman?.mapLatitude ?? 'default_latitude',
        mapLongitude: _longitude?.toString() ?? fetchedCraftsman?.mapLongitude ?? 'default_longitude',
      );


      final result = await repository.updateCraftsman(craftsman);
      result.fold(
            (failure) => throw Exception(failure.message),
            (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Craftsman Info"),
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
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter name" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter location" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _yearsOfExperienceController,
                decoration: InputDecoration(labelText: "Years of Experience"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter years of experience";
                  }
                  final years = int.tryParse(value);
                  if (years == null || years < 0) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "Category"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter category" : null,
              ),
              ElevatedButton(
                onPressed: _getLocation,
                child: const Text('تحديد الموقع'),
              ),
              if (_latitude != null && _longitude != null)
                Text("الموقع: خط العرض $_latitude, خط الطول $_longitude"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCraftsmanProfile,
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
      throw Exception("Failed to upload image: $e");
    }
  }
}