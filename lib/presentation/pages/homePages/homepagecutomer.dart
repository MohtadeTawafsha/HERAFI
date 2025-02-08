import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/pages/account/components-of-craftsman/craftsman-profile-Page.dart';
import 'package:herafi/presentation/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../themes/colors.dart';
import '../CraftsmansearchPage.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  bool showCraftsmen = false;
  String selectedCategory = '';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client;

  final List<Map<String, String>> services = [
    {'name': 'السباكة', 'icon': 'lib/core/utils/images/سباكة.png'},
    {'name': 'النجارة', 'icon': 'lib/core/utils/images/نجارة.png'},
    {'name': 'الكهرباء', 'icon': 'lib/core/utils/images/كهرباء.png'},
    {'name': 'الطلاء', 'icon': 'lib/core/utils/images/طلاء.png'},
    {'name': 'البناء', 'icon': 'lib/core/utils/images/بناء.png'},
    {'name': 'الزراعة', 'icon': 'lib/core/utils/images/مزارع.png'},
    {'name': 'الميكانيك', 'icon': 'lib/core/utils/images/ميكانيكي.png'},
    {'name': 'الحدادة', 'icon': 'lib/core/utils/images/حداد.png'},
    {'name': 'التكييف والتبريد', 'icon': 'lib/core/utils/images/تكييف.png'},
    {'name': 'النقل', 'icon': 'lib/core/utils/images/نقل.png'},
    {'name': 'الخياطة', 'icon': 'lib/core/utils/images/خياطة.png'},
    {'name': 'التعليم الخصوصي', 'icon': 'lib/core/utils/images/مدرس خصوصي.png'},
    {'name': 'الصيانة المنزلية', 'icon': 'lib/core/utils/images/الصيانة المنزلية.png'},
    {'name': 'التجميل', 'icon': 'lib/core/utils/images/تجميل.png'},
    {'name': 'تنظيف المنازل', 'icon': 'lib/core/utils/images/تنظيف المنازل.png'},
    {'name': 'تصليح الأجهزة الإلكترونية', 'icon': 'lib/core/utils/images/circuit.png'},
    {'name': 'الطباعة والتغليف', 'icon': 'lib/core/utils/images/الطباعة والتغليف.png'},
    {'name': 'تصميم الديكور', 'icon': 'lib/core/utils/images/تصميم الديكور.png'},
    {'name': 'الإصلاحات العامة', 'icon': 'lib/core/utils/images/repair.png'},
    {'name': 'الطهي والتموين', 'icon': 'lib/core/utils/images/الطهي والتموين.png'},
    {'name': 'النجدة والطوارئ', 'icon': 'lib/core/utils/images/support.png'},
    {'name': 'الاستشارات الهندسية', 'icon': 'lib/core/utils/images/الاستشارات الهندسية.png'},
    {'name': 'الاستشارات القانونية', 'icon': 'lib/core/utils/images/الاستشارات القانونية.png'},
    {'name': 'التصوير', 'icon': 'lib/core/utils/images/التصوير.png'},
  ];

  Future<List<Map<String, dynamic>>> fetchCraftsmenByCategory(String category) async {
    final response = await supabase
        .from('craftsman')
        .select(
        '*, users(name, image, location), ratings(work_perfection, behavior, respect_deadlines), availability(available)')
        .eq('category', category)
        .then((value) => value as List<dynamic>)
        .catchError((error) {
      throw Exception('Failed to fetch craftsmen: $error');
    });

    return response.map((item) => item as Map<String, dynamic>).toList();
  }

  double calculateAverageRating(List<dynamic> ratings) {
    if (ratings.isEmpty) return 0.0;

    double total = 0.0;
    for (final rating in ratings) {
      total += ((rating['work_perfection'] ?? 0) +
          (rating['behavior'] ?? 0) +
          (rating['respect_deadlines'] ?? 0)) /
          3;
    }
    return total / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'الخدمات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CraftsmanListPage()),
              );
            },
          ),
          // AI Icon
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () {
              Get.toNamed(AppRoutes.chatbot);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: showCraftsmen
                ? _buildCraftsmenList()
                : _buildServicesAndCraftsmenView(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesAndCraftsmenView() {
    final filteredServices = services
        .where((service) =>
        service['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              showCraftsmen = true;
              selectedCategory = filteredServices[index]['name']!;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  filteredServices[index]['icon']!,
                  width: 60,
                  height: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  filteredServices[index]['name']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCraftsmenList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCraftsmenByCategory(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'لم يتم العثور على حرفيين',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final craftsmen = snapshot.data!;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: (){
                    setState(() {
                      showCraftsmen=false;
                    });},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: ThemeColors.goldColor,
                    size: 25.sp,
                  )),
              craftsmen.isNotEmpty?Expanded(
                child: ListView.builder(
                  itemCount: craftsmen.length,
                  itemBuilder: (context, index) {
                    final craftsman = craftsmen[index];
                    final user = craftsman['users'];
                    final ratings = craftsman['ratings'] as List<dynamic>;
                    final availability = craftsman['availability'] as List<dynamic>;

                    final averageRating = calculateAverageRating(ratings);
                    final isAvailable = availability.isNotEmpty
                        ? availability.first['available'] as bool
                        : false;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CraftsmanProfilePage(
                              craftsmanId: craftsman['id'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: user['image'] != null
                                        ? NetworkImage(user['image'])
                                        : null,
                                    child: user['image'] == null
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user['location'] ?? 'Location unknown',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white54,
                                          ),
                                        ),
                                        Text(
                                          selectedCategory,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white54,
                                          ),)
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: isAvailable ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    return Icon(
                                      i < averageRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Years of Experience: ${craftsman['years_of_experience']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ):Center(
                child: Text(
                  'لم يتم العثور على حرفيين',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}