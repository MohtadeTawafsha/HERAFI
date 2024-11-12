import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  DateTime? _selectedDate;
  File? _profileImage;
  int? userId;
  String? imageUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImageToFirebase() async {
    if (_profileImage == null) return;

    try {
      String fileName =
          'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(_profileImage!);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl;
      });

      if (userId != null) {
        await supabase.from('craftsman').update({
          'image': imageUrl,
        }).eq('id', 123);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفع الصورة وتحديث البيانات بنجاح!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> getData() async {
    try {
      final data = await supabase.from('craftsman').select().limit(1).single();

      setState(() {
        userId = data['id'];
        nameController.text = data['Name'] ?? '';
        emailController.text = data['email'] ?? '';
        cityController.text = data['City'] ?? '';
        areaController.text = data['Area'] ?? '';
        _selectedDate = DateTime.tryParse(data['Date-Of-Barth'] ?? '');
        imageUrl = data['image'];
      });
    } catch (error) {}
  }

  Future<void> updateData() async {
    if (userId == null) return;

    try {
      await supabase.from('craftsman').update({
        'Name': nameController.text,
        'email': emailController.text,
        'City': cityController.text,
        'Area': areaController.text,
        'Date-Of-Barth': _selectedDate?.toIso8601String(),
      }).eq('id', 123);

      if (_profileImage != null) {
        await uploadImageToFirebase();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التعديل بنجاح!')),
      );

      Navigator.pop(context);
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider<Object>
                      : (imageUrl != null ? NetworkImage(imageUrl!) : null),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date of Birth: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: areaController,
              decoration: InputDecoration(labelText: 'Area'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateData,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
