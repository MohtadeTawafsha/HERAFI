import 'package:flutter/material.dart';
import 'package:herafi/data/repositroies/userRepositoryImp.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import '../../../../data/repositroies/jobRepositoryImp.dart';
import '../../../../domain/entites/customer.dart';
import '../../../../domain/entites/job.dart';
import '../../../Widgets/craftsmanJobWidget.dart';

class CustomerProfilePage extends StatefulWidget {
  final String customerId;

  const CustomerProfilePage({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  CustomerEntity? customer;
  List<JobEntity> jobs = [];
  bool isLoading = true;

  final jobRepository = JobRepositoryImpl();

  @override
  void initState() {
    super.initState();
    fetchCustomerProfile();
  }

  Future<void> fetchCustomerProfile() async {
    setState(() => isLoading = true);

    try {
      // Fetch customer details
      final customerResult = await userRepositoryImp().fetchUserData(userId: widget.customerId);
      customerResult.fold(
            (failure) => _showError(failure.message),
            (data) => customer = data as CustomerEntity,
      );

      // Fetch jobs posted by the customer
      final jobResult = await jobRepository.fetchCustomerForCustomer(widget.customerId);
      jobResult.fold(
            (failure) => _showError(failure.message),
            (data) => jobs = data.where((job) => job.customer.id == widget.customerId).toList(),
      );
    } catch (e) {
      _showError("حدث خطأ: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF332E2E),
      appBar: AppBar(
        title: const Text('ملف العميل'),
        leading: leadingAppBar(),

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customer == null
          ? const Center(child: Text("العميل غير موجود"))
          : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerDetails(),
                ...jobs.map((job) => craftsmanJobWidget(job: job,)).toList(),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildCustomerDetails() {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:customer!.image.isNotEmpty? NetworkImage(customer!.image):AssetImage('lib/core/utils/images/profile.png')
              ),
              const SizedBox(height: 10),
              Text(
                customer!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "الهاتف: ${customer!.phoneNumber}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                "الموقع: ${customer!.location}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
