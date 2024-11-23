import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WorkDetailScreen extends StatefulWidget {
  final String? title;
  final String? description;
  final String imagePath;
  final Function(String, String, String) onSave;
  final VoidCallback? onDelete;

  WorkDetailScreen({
    this.title,
    this.description,
    required this.imagePath,
    required this.onSave,
    this.onDelete,
  });

  @override
  _WorkDetailScreenState createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String imagePath;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
    imagePath = widget.imagePath;
  }

  Future<void> _editImage() async {
    final picker = ImagePicker();
    final newImage = await picker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        imagePath = newImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Work Detail"),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(
                titleController.text,
                descriptionController.text,
                imagePath,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _editImage,
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
