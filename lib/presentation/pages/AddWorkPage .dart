import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddWorkPage extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? imagePath;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Work')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImagePicked(pickedFile.path);
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: imagePath != null
                        ? DecorationImage(
                      image: FileImage(File(imagePath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imagePath == null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            size: 40, color: Colors.black54),
                        SizedBox(height: 8),
                        Text(
                          "Add Image",
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
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAddWork,
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}