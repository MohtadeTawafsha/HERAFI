import 'package:flutter/material.dart';

class RegisterCraftsman extends StatelessWidget {
  const RegisterCraftsman({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب الحرفي'),backgroundColor: Colors.blue),
      body: Center(
        child: const Text(
          'صفحة تسجيل حساب الحرفي',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}