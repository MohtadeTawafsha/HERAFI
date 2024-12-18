import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/remotDataSource/customerDataSource.dart';
import '../../data/repositroies/customerRepositoryImp.dart';
import '../../data/repositroies/jobRepositoryImp.dart';
import '../../domain/entites/customer.dart';
import '../../domain/entites/job.dart';

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

  // Correct initialization
  final customerRepository = CustomerRepositoryImpl(
    CustomerRemoteDataSource(Supabase.instance.client, FirebaseAuth.instance),
  );

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
      final customerResult = await customerRepository.fetchCustomerById(widget.customerId);
      customerResult.fold(
            (failure) => _showError(failure.message),
            (data) => customer = data,
      );

      // Fetch jobs posted by the customer
      final jobResult = await jobRepository.fetchJobs(1, "");
      jobResult.fold(
            (failure) => _showError(failure.message),
            (data) => jobs = data.where((job) => job.customer.id == widget.customerId).toList(),
      );
    } catch (e) {
      _showError("Something went wrong: $e");
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
      backgroundColor: const Color(0xFF332E2E), // Light background
      appBar: AppBar(
        title: const Text('Customer Profile'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customer == null
          ? const Center(child: Text("Customer not found"))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerDetails(),
            const SizedBox(height: 20),
            _buildJobList(),
          ],
        ),
      ),
    );
  }

  /// Profile Section
  Widget _buildCustomerDetails() {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            color: Colors.black,
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
                backgroundImage: NetworkImage(customer!.image.isNotEmpty
                    ? customer!.image
                    : 'https://example.com/default_image.png'),
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
                "Phone: ${customer!.phoneNumber}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                "Location: ${customer!.location}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Center(child: const SizedBox(height: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.black, Colors.grey], // Gradient from black to gray
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), // Rounded edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3), // Slight bottom shadow
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Jobs Posted",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(
              color: Colors.white70,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            ...jobs.map((job) => _buildJobCard(job)).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  Widget _buildJobCard(JobEntity job) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Job Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              job.image.isNotEmpty
                  ? job.image
                  : 'https://example.com/default_job_image.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          // Job Title
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          // Job Description
          Text(
            job.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Date Posted
          Text(
            "Posted on: ${job.getDateFormat()}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Action Buttons: Location and Contact
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location Button
              IconButton(
                icon: const Icon(Icons.location_on, color: Colors.teal),
                onPressed: () {
                  // Handle location click
                },
              ),
              const SizedBox(width: 20),
              // Contact Button
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                onPressed: () {
                  // Handle contact click
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}
