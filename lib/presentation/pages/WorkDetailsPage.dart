import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:herafi/domain/entites/work.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/data/repositroies/WorksRepositoryImpl.dart';
import 'package:herafi/data/remotDataSource/WorksRemoteDataSource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkDetailsPage extends StatefulWidget {
  final WorkEntity work;

  WorkDetailsPage({required this.work});

  @override
  _WorkDetailsPageState createState() => _WorkDetailsPageState();
}

class _WorkDetailsPageState extends State<WorkDetailsPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String? imagePath;
  late WorksRepositoryImpl worksRepository;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    worksRepository = WorksRepositoryImpl(
      WorksRemoteDataSource(Supabase.instance.client),
    );
    titleController = TextEditingController(text: widget.work.title);
    descriptionController = TextEditingController(text: widget.work.description);
    imagePath = widget.work.image;
  }

  Future<String?> _uploadImageToFirebase(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('works/$fileName');
      final uploadTask = await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateWork() async {
    setState(() => isLoading = true);

    final downloadUrl = imagePath!.startsWith('http')
        ? imagePath
        : await _uploadImageToFirebase(imagePath!);

    if (downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image.')),
      );
      setState(() => isLoading = false);
      return;
    }

    final updatedWork = WorkEntity(
      id: widget.work.id,
      craftsmanId: widget.work.craftsmanId,
      image: downloadUrl,
      title: titleController.text,
      description: descriptionController.text,
      createdAt: widget.work.createdAt,
    );

    final result = await worksRepository.updateWork(updatedWork);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating work: ${failure.message}')),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Work updated successfully!')),
        );
        Navigator.of(context).pop(updatedWork); // إرجاع العمل المحدث
      },
    );

    setState(() => isLoading = false);
  }

  Future<void> _deleteWork() async {
    setState(() => isLoading = true);

    final result = await worksRepository.deleteWork(widget.work.id);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting work: ${failure.message}')),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Work deleted successfully!')),
        );
        Navigator.of(context).pop(null); // حذف العمل وإغلاق الصفحة
      },
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Work')),
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
                    setState(() {
                      imagePath = pickedFile.path;
                    });
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
                            image: imagePath!.startsWith('http')
                                ? NetworkImage(imagePath!)
                                : FileImage(File(imagePath!)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : _updateWork,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _deleteWork,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
