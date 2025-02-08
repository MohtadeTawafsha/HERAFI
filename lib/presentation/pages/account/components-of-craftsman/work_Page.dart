import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/data/remotDataSource/WorksRemoteDataSource.dart';
import 'package:herafi/data/repositroies/WorksRepositoryImpl.dart';
import 'package:herafi/domain/entites/work.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../AddWorkPage .dart';
import '../../WorkDetailsPage.dart';

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
        SnackBar(content: Text('Error: User is not logged in.')),
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

  Future<void> _saveWork() async {
    final craftsmanId = FirebaseAuth.instance.currentUser!.uid;

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
        id: 0,
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
          _fetchWorks();
          Navigator.of(context).pop();
        },
      );

      setState(() {
        imagePath = null;
        titleController.clear();
        descriptionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  Future<String?> _uploadImageToFirebase(String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = FirebaseStorage.instance
          .ref()
          .child('works')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
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
            _saveWork();
          },
        ),
      ),
    );
  }

  void _navigateToWorkDetails(WorkEntity work) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkDetailsPage(work: work),
      ),
    );

    _fetchWorks();
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
                  fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(
                  work.image,
                ))),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الاعمال')),
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
