import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/data/remotDataSource/WorksRemoteDataSource.dart';
import 'package:herafi/data/repositroies/WorksRepositoryImpl.dart';
import 'package:herafi/domain/entites/work.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AddWorkPage .dart';
import 'WorkDetailsPage.dart';

class WorkPage extends StatefulWidget {
  @override
  _WorkPageState createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  late WorksRepositoryImpl worksRepository;
  List<WorkEntity> works = [];
  String? imagePath;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    worksRepository = WorksRepositoryImpl(
      WorksRemoteDataSource(Supabase.instance.client),
    );
    _fetchWorks();
  }

  Future<void> _fetchWorks() async {
    setState(() => isLoading = true);

    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;
    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in.')),
      );
      setState(() => isLoading = false);
      return;
    }

    final result = await worksRepository.fetchWorks(craftsmanId);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching works: ${failure.message}')),
      ),
      (fetchedWorks) {
        setState(() => works = fetchedWorks);
      },
    );

    setState(() => isLoading = false);
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

  Future<void> _addWork() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in.')),
      );
      return;
    }

    if (imagePath != null &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      final downloadUrl = await _uploadImageToFirebase(imagePath!);
      if (downloadUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image to Firebase.')),
        );
        return;
      }

      final newWork = WorkEntity(
        id: 0, // يتم إنشاؤه تلقائيًا في قاعدة البيانات
        craftsmanId: craftsmanId,
        image: downloadUrl,
        title: titleController.text,
        description: descriptionController.text,
        createdAt: DateTime.now(),
      );

      final result = await worksRepository.insertWork(newWork);
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding work: ${failure.message}')),
        ),
        (_) {
          _fetchWorks(); // تحديث البيانات مباشرة
          Navigator.of(context).pop(); // العودة للشاشة السابقة
        },
      );

      setState(() {
        imagePath = null;
        titleController.clear();
        descriptionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
    }
  }

  void _navigateToAddWork() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkPage(
          titleController: titleController,
          descriptionController: descriptionController,
          imagePath: imagePath,
          onImagePicked: (pickedImagePath) {
            setState(() {
              imagePath = pickedImagePath;
            });
          },
          onAddWork: () {
            _addWork();
            Navigator.pop(context); // العودة للشاشة السابقة
          },
        ),
      ),
    );
  }

  void _navigateToWorkDetails(WorkEntity work) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkDetailsPage(work: work),
      ),
    );
  }

  Widget buildWorksGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: works.length,
      itemBuilder: (context, index) {
        final work = works[index];
        return GestureDetector(
          onTap: () => _navigateToWorkDetails(work),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(work.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Portfolio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add, size: 32),
                onPressed: _navigateToAddWork,
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildWorksGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
