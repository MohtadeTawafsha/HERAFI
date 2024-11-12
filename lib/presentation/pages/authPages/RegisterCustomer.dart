import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({Key? key}) : super(key: key);

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل حساب العميل'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الأول';
                    }
                    return null;
                  },
                ),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأخير'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الأخير';
                    }
                    return null;
                  },
                ),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),

                // Date of Birth
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                        "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال تاريخ الميلاد';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Submit Button
                CustomButton(
                  icon: Icons.check,
                  label: 'تسجيل',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.offAllNamed(AppRoutes.home);
                    }
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}

// Custom Button Widget
class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}