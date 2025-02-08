import 'dart:io';

import 'package:flutter/material.dart';
import 'package:herafi/data/repositroies/certificateRepositoryImp.dart';
import 'package:herafi/global/setOfMethods.dart';
import 'package:herafi/presentation/Widgets/FullScreenImage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
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
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result = await repository.fetchCertificates(user.uid);
    result.fold(
          (failure) {
        setState(() {
          isLoading = false;
          certificates = [];
        });
      },
          (data) {
        setState(() {
          certificates = data;
          isLoading = false;
        });
      },
    );
  }

  Future<void> _uploadSelectedCertificate() async {
    if (selectedImage == null) return;

    setState(() {
      isLoading = true;
    });

    final certificate = CertificateEntity(
      id: 0,
      createdAt: DateTime.now(),
      craftsmanId: FirebaseAuth.instance.currentUser!.uid,
      image: null,
    );

    final result = await repository.insertCertificateWithImage(certificate, selectedImage!);
    result.fold(
          (failure) {
        setState(() {
          isLoading = false;
        });
      },
          (_) {
        _loadCertificates();
        setState(() {
          selectedImage = null;
        });
      },
    );
  }

  Future<void> _deleteCertificate(int id) async {
    setState(() {
      isLoading = true;
    });

    final result = await repository.deleteCertificate(id);
    result.fold(
          (failure) {
        setState(() {
          isLoading = false;
        });
      },
          (_) {
        _loadCertificates();
      },
    );
  }

  void _viewPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _pickImage() async {
    final imagePath = await globalMethods().selectPhoto(context: context);
    if (imagePath != null) {
      setState(() {
        selectedImage = File(imagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشهادات'),
        leading: leadingAppBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add,color: Colors.white,),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : certificates.isEmpty
          ? const Center(
        child: Text(
          "لا توجد شهادات مرفوعة حاليًا",
          style: TextStyle(fontSize: 16),
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
            title: Text('الشهادة رقم ${cert.id}'),
            subtitle: Text(cert.createdAt.toString(),style: TextStyle(color: Colors.grey),),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCertificate(cert.id),
            ),
          );
        },
      ),
      floatingActionButton: selectedImage != null
          ? FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(2),
        onPressed: _uploadSelectedCertificate,
        child:  Text("حفظ",style: TextStyle(color: Theme.of(context).focusColor,fontSize: 15),),
      )
          : null,
    );
  }
}
