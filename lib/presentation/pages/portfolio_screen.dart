import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> works = [];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addNewWork() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkDetailScreen(
            onSave: (String title, String description, String imagePath) {
              setState(() {
                works.add({
                  'title': title,
                  'description': description,
                  'imagePath': imagePath,
                });
              });
            },
            imagePath: image.path,
          ),
        ),
      );
    }
  }

  void _viewWorkDetail(int index) {
    final work = works[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkDetailScreen(
          title: work['title'],
          description: work['description'],
          imagePath: work['imagePath'],
          onSave: (String title, String description, String imagePath) {
            setState(() {
              works[index] = {
                'title': title,
                'description': description,
                'imagePath': imagePath,
              };
            });
          },
          onDelete: () {
            setState(() {
              works.removeAt(index);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _savePortfolio() {
    print("Portfolio saved:");
    print("About me: ${descriptionController.text}");
    print("Previous works: $works");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Portfolio saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portfolio"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePortfolio,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'About me',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Previous work:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _addNewWork,
                  child: Icon(Icons.add_box, size: 50),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: works.map((work) {
                        int index = works.indexOf(work);
                        return GestureDetector(
                          onTap: () => _viewWorkDetail(index),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(
                              File(work['imagePath']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
