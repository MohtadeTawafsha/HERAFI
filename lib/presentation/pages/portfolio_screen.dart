import 'dart:io';
import 'package:flutter/material.dart';
import 'package:herafi/presentation/pages/WorkDetailScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  List<Map<String, dynamic>> works = [];

  @override
  void initState() {
    super.initState();
    _fetchWorks();
  }

  Future<void> _fetchWorks() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final response = await supabaseClient
        .from('works')
        .select('*')
        .eq('craftsman_id', craftsmanId)
        .order('created_at', ascending: false)
        .execute();

    if (response.error == null) {
      setState(() {
        works = (response.data as List)
            .map((work) => {
                  'id': work['id'],
                  'title': work['title'],
                  'description': work['description'],
                  'imagePath': work['image'],
                })
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching works: ${response.error!.message}')),
      );
    }
  }

  Future<String> _uploadImageToFirebase(String imagePath, String workId) async {
    final file = File(imagePath);
    final storageRef = firebaseStorage.ref().child('works/$workId/${file.uri.pathSegments.last}');

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> _addNewWork() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkDetailScreen(
            onSave: (String title, String description, String imagePath) async {
              try {
                final response = await supabaseClient
                    .from('works')
                    .insert({
                      'craftsman_id': craftsmanId,
                      'title': title,
                      'description': description,
                      'image': '',
                    })
                    .select('id')
                    .execute();

                if (response.error != null) {
                  throw Exception('Failed to add work: ${response.error!.message}');
                }

                final workId = response.data[0]['id'];

                // رفع الصورة إلى Firebase
                final imageUrl = await _uploadImageToFirebase(imagePath, workId);

                // تحديث رابط الصورة في Supabase
                await supabaseClient.from('works').update({'image': imageUrl}).eq('id', workId);

                setState(() {
                  works.add({
                    'id': workId,
                    'title': title,
                    'description': description,
                    'imagePath': imageUrl,
                  });
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding work: $e')),
                );
              }
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
          onSave: (String title, String description, String imagePath) async {
            try {
              // رفع صورة جديدة إذا تم تعديلها
              String imageUrl = work['imagePath'];
              if (imagePath != work['imagePath']) {
                imageUrl = await _uploadImageToFirebase(imagePath, work['id']);
              }

              // تحديث البيانات في Supabase
              await supabaseClient.from('works').update({
                'title': title,
                'description': description,
                'image': imageUrl,
              }).eq('id', work['id']);

              setState(() {
                works[index] = {
                  'id': work['id'],
                  'title': title,
                  'description': description,
                  'imagePath': imageUrl,
                };
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating work: $e')),
              );
            }
          },
          onDelete: () async {
            try {
              // حذف العمل من Supabase
              await supabaseClient.from('works').delete().eq('id', work['id']);

              setState(() {
                works.removeAt(index);
              });

              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting work: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portfolio"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            child: Image.network(
                              work['imagePath'],
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
