import 'dart:io';

import 'package:flutter/material.dart';
import 'package:herafi/data/repositroies/certificateRepositoryImp.dart';
import 'package:herafi/presentation/Widgets/FullScreenImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:herafi/data/remotDataSource/certificateRemotDataSource.dart';
import 'package:herafi/domain/entites/certificate.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final repository = CertificateRepositoryImpl(
    CertificateRemoteDataSource(
      Supabase.instance.client,
      FirebaseAuth.instance,
      FirebaseStorage.instance,
    ),
  );

  List<CertificateEntity> certificates = [];
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  /// Load certificates from the repository
  Future<void> _loadCertificates() async {
    setState(() {
      isLoading = true; // عرض مؤشر التحميل
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false; // إخفاء التحميل
      });
      return;
    }

    final result = await repository.fetchCertificates(user.uid);
    result.fold(
          (failure) {
        // تجاهل طباعة الأخطاء إلى الكونسول
        setState(() {
          isLoading = false; // إخفاء التحميل
          certificates = []; // قائمة فارغة
        });
      },
          (data) {
        setState(() {
          certificates = data; // تحديث الشهادات إذا وجدت
          isLoading = false; // إخفاء التحميل
        });
      },
    );
  }

  /// Add a new certificate by capturing an image from the camera
  Future<void> _addCertificateFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _uploadCertificate(File(pickedFile.path));
    }
  }

  /// Add a new certificate by selecting an image from the gallery
  Future<void> _addCertificateFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadCertificate(File(pickedFile.path));
    }
  }

  /// Upload a certificate and update the UI
  Future<void> _uploadCertificate(File file) async {
    setState(() {
      isLoading = true; // عرض مؤشر التحميل
    });

    final certificate = CertificateEntity(
      id: 0, // ID is auto-generated
      createdAt: DateTime.now(),
      craftsmanId: FirebaseAuth.instance.currentUser!.uid,
      image: null, // Will be updated after upload
    );

    final result = await repository.insertCertificateWithImage(certificate, file);
    result.fold(
          (failure) {
        setState(() {
          isLoading = false; // إخفاء التحميل
        });
      },
          (_) {
        _loadCertificates(); // تحديث الشهادات بعد الإدخال
      },
    );
  }

  /// Delete a certificate
  Future<void> _deleteCertificate(int id) async {
    setState(() {
      isLoading = true; // عرض مؤشر التحميل
    });

    final result = await repository.deleteCertificate(id);
    result.fold(
          (failure) {
        setState(() {
          isLoading = false; // إخفاء التحميل
        });
      },
          (_) {
        _loadCertificates(); // تحديث الشهادات بعد الحذف
      },
    );
  }

  /// View the photo in full-screen
  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // عرض مؤشر التحميل
          : certificates.isEmpty
          ? const Center(
        child: Text(
          "No certificates uploaded yet", // عرض رسالة عند عدم وجود شهادات
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return ListTile(
            leading: cert.image != null
                ? GestureDetector(
              onTap: () => _viewPhoto(cert.image!),
              child: Image.network(
                cert.image!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
                : const Icon(Icons.image, size: 50),
            title: Text('Certificate #${cert.id}'),
            subtitle: Text(cert.createdAt.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCertificate(cert.id),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: _addCertificateFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take Photo"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addCertificateFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Upload Photo"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}