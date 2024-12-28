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

import 'comments-Page.dart';


class CraftsmanProfilePage extends StatefulWidget {
  final String craftsmanId;

  const CraftsmanProfilePage({Key? key, required this.craftsmanId}) : super(key: key);

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
  double averageRating = 0.0;
  Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final craftsmanId = widget.craftsmanId;

    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Craftsman ID not provided.')),
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
        ...userResponse,
      });

      // Fetch ratings
      final ratingsResponse = await Supabase.instance.client
          .from('ratings')
          .select('work_perfection, behavior, respect_deadlines')
          .eq('craftsman_id', craftsmanId); // شرط الحرفي المحدد فقط

      if (ratingsResponse != null) {
        int totalRatings = ratingsResponse.length;
        int totalStars = 0;

        for (var rating in ratingsResponse) {
          if (rating['work_perfection'] != null &&
              rating['behavior'] != null &&
              rating['respect_deadlines'] != null) {
            int overallRating = ((rating['work_perfection'] +
                rating['behavior'] +
                rating['respect_deadlines']) ~/
                3); // متوسط لكل تقييم

            totalStars += overallRating;
            starCounts[overallRating] = (starCounts[overallRating] ?? 0) + 1;
          }
        }

        averageRating =
        totalRatings > 0 ? totalStars / totalRatings : 0.0; // متوسط التقييم
      }

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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCraftsmanViewingOwnProfile = currentUserId == widget.craftsmanId;

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
            _buildCraftsmanInfoSection(isCraftsmanViewingOwnProfile),
            _buildRatingSection(),

            const Divider(),
            TabBar(
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'certificates'),
                Tab(text: 'Works'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCertificatesSection(),
                  _buildWorksSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isCraftsmanAvailable() {
    // إذا كانت الإتاحة بسيطة أو مجدولة والحرفي متاح
    return availability.any((entry) =>
    entry.available &&
        (entry.availabilityType == 'simple' ||
            (entry.availabilityType == 'schedule' && entry.dayOfWeek != null)));
  }


  Widget _buildCraftsmanInfoSection(bool isCraftsmanViewingOwnProfile) {
    final isAvailable = isCraftsmanAvailable();

    // تحقق إذا كانت الحالة simple و available == true
    final shouldHideIcon = availability.any(
          (entry) => entry.availabilityType == 'simple' && entry.available,
    );

    final unavailabilityReason = availability.firstWhere(
          (entry) => !entry.available && entry.unavailabilityReason != null,
      orElse: () => AvailabilityModel(
        id: 0,
        craftsmanId: '',
        availabilityType: '',
        dayOfWeek: null,
        available: true,
        unavailabilityReason: '',
      ),
    ).unavailabilityReason;

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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    isAvailable
                        ? 'I’m available to work'
                        : 'I’m not available',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // إذا تحقق الشرط لإخفاء الأيقونة، لا يتم عرضها
              if (!shouldHideIcon)
                IconButton(
                  icon: isAvailable
                      ? const Icon(Icons.calendar_today, size: 24)
                      : const Icon(Icons.info, size: 24, color: Colors.orange),
                  onPressed: () {
                    if (isAvailable) {
                      _showAvailabilityDays();
                    } else {
                      _showUnavailabilityReason(unavailabilityReason);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnavailabilityReason(String? reason) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Unavailability Reason:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // لون العنوان
            ),
          ),
          content: Text(
            reason?.isNotEmpty == true
                ? reason!
                : 'No reason provided.', // النص الافتراضي إذا لم يتم إدخال السبب
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black, // لون النص
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.black, // لون الزر
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showAvailabilityDays() {
    final highlightedDays = availability
        .where((entry) => entry.available && entry.dayOfWeek != null)
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
              final isHighlighted = highlightedDays.contains(day);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.green : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : Colors.black,
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
  }


  Widget _buildRatingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عرض النجوم مع التقييم المتوسط
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // عرض التقييم المتوسط كرقم
            Text(
              averageRating.toStringAsFixed(1), // عرض الرقم بشكل عشري
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating.ceil() // استخدام ceil للعرض الصحيح
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
        const SizedBox(width: 16), // مسافة بين العمودين
        // الشريط الأفقي من 0 إلى 5
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(5, (index) {
                int star = 5 - index; // التقييم يبدأ من 5 إلى 1
                double totalRatings =
                starCounts.values.fold(0, (a, b) => a + b).toDouble(); // حساب إجمالي التقييمات
                double percentage = totalRatings > 0
                    ? (starCounts[star]?.toDouble() ?? 0) / totalRatings
                    : 0.0; // حساب نسبة النجوم

                // طباعة للتأكد من القيم
                print('Star $star: Count = ${starCounts[star]}, Percentage = $percentage');

                return Row(
                  children: [
                    Text('$star'), // رقم النجمة
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0), // التأكد من أن القيمة ضمن النطاق الصحيح
                        backgroundColor: Colors.grey[300],
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${starCounts[star] ?? 0}'), // عدد النجوم
                  ],
                );
              }),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsPage(craftsmanId: widget.craftsmanId),
                    ),
                  );
                },
                child: const Text(
                  'See comments',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildCertificatesSection() {
    return certificates.isEmpty
        ? const Center(child: Text('No Certificates available.'))
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

  Widget _buildWorksSection() {
    return works.isEmpty
        ? const Center(child: Text('No Work items available.'))
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
        return GestureDetector(
          onTap: () {
            _showWorkDetailsDialog(context, works[index]);
          },
          child: Card(
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
          ),
        );
      },
    );
  }
  void _showWorkDetailsDialog(BuildContext context, WorkEntity work) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: work.image != null
                        ? DecorationImage(
                      image: NetworkImage(work.image!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: work.image == null
                      ? const Center(
                    child: Text(
                      "No Image Available",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  "Title:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black, // لون النص
                  ),
                ),
                Text(
                  work.title ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black, // لون النص
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Description:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black, // لون النص
                  ),
                ),
                Text(
                  work.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black, // لون النص
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black), // لون النص
              ),
            ),
          ],
        );
      },
    );
  }
}
