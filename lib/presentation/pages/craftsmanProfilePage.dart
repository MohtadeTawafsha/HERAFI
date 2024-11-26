import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/data/models/WorkModel.dart';
import 'package:herafi/data/models/availabilityModel.dart';
import 'package:herafi/data/models/certificateModel.dart';
import 'package:herafi/data/models/craftsmanModel.dart';
import 'package:herafi/data/models/userModel.dart';
import 'package:herafi/domain/entites/availability.dart';
import 'package:herafi/domain/entites/certificate.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/domain/entites/work.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CraftsmanProfilePage extends StatefulWidget {
  const CraftsmanProfilePage({Key? key}) : super(key: key);

  @override
  _CraftsmanProfilePageState createState() => _CraftsmanProfilePageState();
}

class _CraftsmanProfilePageState extends State<CraftsmanProfilePage> {
  UserEntity? user;
  CraftsmanEntity? craftsman;
  List<CertificateEntity> certificates = [];
  List<AvailabilityEntity> availability = [];
  List<WorkEntity> works = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      // Fetch user data
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', craftsmanId)
          .single();
      user = UserModel.fromJson(userResponse);

      // Fetch craftsman data
      final craftsmanResponse = await Supabase.instance.client
          .from('craftsman')
          .select()
          .eq('id', craftsmanId)
          .single();
      craftsman = CraftsmanModel.fromJson({
        ...craftsmanResponse,
        ...userResponse, // Merge user fields for craftsman
      });

      // Fetch certificates
      final certificatesResponse = await Supabase.instance.client
          .from('certificate')
          .select()
          .eq('craftsman_id', craftsmanId);
      certificates = (certificatesResponse as List)
          .map((json) => CertificateModel.fromJson(json))
          .toList();

      // Fetch availability
      final availabilityResponse = await Supabase.instance.client
          .from('availability')
          .select()
          .eq('craftsman_id', craftsmanId);
      availability = (availabilityResponse as List)
          .map((json) => AvailabilityModel.fromJson(json))
          .toList();

      // Fetch works
      final worksResponse = await Supabase.instance.client
          .from('works')
          .select()
          .eq('craftsman_id', craftsmanId);
      works = (worksResponse as List)
          .map((json) => WorkModel.fromJson(json))
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Craftsman Profile'),
        ),
        body: Column(
          children: [
            _buildCraftsmanInfoSection(),
            const Divider(),
            const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Certificates'),
                Tab(text: 'Works'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDiplomaSection(),
                  _buildPortfolioSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCraftsmanInfoSection() {
    final isAvailable = availability.any(
            (entry) => entry.available && entry.availabilityType == 'simple');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user?.image ?? ''),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(craftsman?.category ?? ''),
                  Text(user?.location ?? ''),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isAvailable ? Icons.circle : Icons.cancel,
                    color: isAvailable ? Colors.green : Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'I’m available to work' : 'I’m not available',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 24),
                onPressed: () {
                  final highlightedDays = availability
                      .where((entry) =>
                  entry.available && entry.dayOfWeek != null)
                      .map((entry) => entry.dayOfWeek!.split(','))
                      .expand((days) => days)
                      .toSet()
                      .toList();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Available Days'),
                        content: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            'Sunday',
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday'
                          ].map((day) {
                            final isHighlighted =
                            highlightedDays.contains(day);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? Colors.green
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isHighlighted
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiplomaSection() {
    return certificates.isEmpty
        ? const Center(child: Text('No Diplomas available.'))
        : GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        return Card(
          child: Image.network(
            certificates[index].image ?? '',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildPortfolioSection() {
    return works.isEmpty
        ? const Center(child: Text('No Portfolio items available.'))
        : GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: works.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  works[index].image ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  works[index].title ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
