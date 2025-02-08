import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddWorkPage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  String? imagePath;
  final Function(String) onImagePicked;
  final VoidCallback onAddWork;

  AddWorkPage({
    required this.titleController,
    required this.descriptionController,
    required this.imagePath,
    required this.onImagePicked,
    required this.onAddWork,
  });

  @override
  State<AddWorkPage> createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة عمل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    widget.onImagePicked(pickedFile.path);
                    widget.imagePath=pickedFile.path;
                  }
                  setState(() {

                  });
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: widget.imagePath != null
                        ? DecorationImage(
                      image: FileImage(File(widget.imagePath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: widget.imagePath == null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            size: 40, color: Colors.black54),
                        SizedBox(height: 8),
                        Text(
                          "إضافة صورة",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                      : null,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: widget.titleController,
                decoration: InputDecoration(labelText: 'العنوان'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: widget.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'الوصف'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: widget.onAddWork,
                child: Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
