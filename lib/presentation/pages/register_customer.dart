import 'package:flutter/material.dart';

class RegisterCustomer extends StatelessWidget {
  const RegisterCustomer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب العميل'),backgroundColor: Colors.blue),
      body: Center(
        child: const Text(
          'صفحة تسجيل حساب العميل',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}