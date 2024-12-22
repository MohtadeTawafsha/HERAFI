import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/CraftsmanViewModel.dart';
import '../../global/constants.dart';

class CraftsmanListPage extends StatefulWidget {
  const CraftsmanListPage({Key? key}) : super(key: key);

  @override
  _CraftsmanListPageState createState() => _CraftsmanListPageState();
}

class _CraftsmanListPageState extends State<CraftsmanListPage> {
  List<CraftsmanViewModel> craftsmen = [];
  List<CraftsmanViewModel> filteredCraftsmen = [];
  bool isLoading = true;

  // متغيرات البحث والفلترة
  String searchQuery = '';
  String? selectedProfession;
  String? selectedCity;
  String? availability;
  double? minRating;

  @override
  void initState() {
    super.initState();
    _fetchCraftsmen();
  }

  // جلب بيانات الحرفيين
  Future<void> _fetchCraftsmen() async {
    try {
      final response = await Supabase.instance.client
          .from('craftsman')
          .select('''
            id,
            users(name, phone_number, image, location, created_at, date_of_birth),
            category,
            years_of_experience,
            ratings (work_perfection, behavior, respect_deadlines),
            availability (available)
          ''')
          .then((data) => data as List<dynamic>);

      setState(() {
        craftsmen = response.map((json) {
          final user = json['users'] as Map<String, dynamic>;

          // معالجة التقييم
          final ratings = json['ratings'] as List<dynamic>?;
          double rating = 0;
          if (ratings != null && ratings.isNotEmpty) {
            final totalRatings = ratings.fold<int>(
              0,
                  (sum, rating) =>
              sum +
                  ((rating['work_perfection'] ?? 0) as num).toInt() +
                  ((rating['behavior'] ?? 0) as num).toInt() +
                  ((rating['respect_deadlines'] ?? 0) as num).toInt(),
            );
            rating = totalRatings / (ratings.length * 3);
          }

          // معالجة الإتاحة
          final availabilityList = json['availability'] as List<dynamic>?;
          final isAvailable = availabilityList != null &&
              availabilityList.isNotEmpty &&
              (availabilityList.first['available'] ?? false);

          return CraftsmanViewModel(
            id: json['id'],
            name: user['name'] ?? 'غير معروف',
            category: json['category'] ?? 'غير معروف',
            location: user['location'] ?? 'غير معروف',
            phoneNumber: user['phone_number'] ?? 'غير معروف',
            image: user['image'],
            rating: rating,
            isAvailable: isAvailable,
          );
        }).toList();

        filteredCraftsmen = List.from(craftsmen);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء جلب البيانات: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // فلترة البيانات
  void _filterCraftsmen() {
    setState(() {
      filteredCraftsmen = craftsmen.where((craftsman) {
        // التحقق من الحرفة
        bool matchesProfession = selectedProfession == null ||
            craftsman.category == selectedProfession;

        // التحقق من المدينة
        bool matchesCity = selectedCity == null || craftsman.location == selectedCity;

        // التحقق من الإتاحة
        bool matchesAvailability = availability == null ||
            craftsman.isAvailable == (availability == 'متاح');

        // التحقق من التقييم
        bool matchesRating = minRating == null || craftsman.rating >= minRating!;

        // التحقق من جميع الشروط
        return matchesProfession && matchesCity && matchesAvailability && matchesRating;
      }).toList();
    });
  }

  // واجهة الفلترة
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'اختر الحرفة',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    fillColor: Colors.black,
                    filled: true,
                  ),
                  dropdownColor: Colors.black,
                  style: TextStyle(color: Colors.white),
                  items: constants.categories
                      .map((profession) =>
                      DropdownMenuItem(value: profession, child: Text(profession)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProfession = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'اختر المدينة',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    fillColor: Colors.black,
                    filled: true,
                  ),
                  dropdownColor: Colors.black,
                  style: TextStyle(color: Colors.white),
                  items: constants.palestinianCities
                      .map((city) =>
                      DropdownMenuItem(value: city, child: Text(city)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الإتاحة',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    fillColor: Colors.black,
                    filled: true,
                  ),
                  dropdownColor: Colors.black,
                  style: TextStyle(color: Colors.white),
                  items: ['متاح', 'غير متاح']
                      .map((availability) =>
                      DropdownMenuItem(value: availability, child: Text(availability)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      availability = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('أدنى تقييم:', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: minRating ?? 0,
                      onChanged: (value) {
                        setState(() {
                          minRating = value;
                        });
                      },
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: minRating?.toStringAsFixed(1),
                      activeColor: Colors.purple,
                      inactiveColor: Colors.yellow,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _filterCraftsmen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('تطبيق الفلاتر'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الحرفيين'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.yellow),
                      hintText: 'ابحث عن الحرفيين',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                      _filterCraftsmen();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.yellow),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCraftsmen.isEmpty
                ? const Center(
              child: Text('لا يوجد حرفيين.', style: TextStyle(color: Colors.white)),
            )
                : ListView.builder(
              itemCount: filteredCraftsmen.length,
              itemBuilder: (context, index) {
                final craftsman = filteredCraftsmen[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(craftsman.image ?? ''),
                    child: craftsman.image == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(craftsman.name, style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رقم الهاتف: ${craftsman.phoneNumber}', style: TextStyle(color: Colors.white70)),
                      Text('التقييم: ${craftsman.rating.toStringAsFixed(1)}/5',
                          style: TextStyle(color: Colors.white70)),
                      Text('المدينة: ${craftsman.location}', style: TextStyle(color: Colors.white70)),
                      Text('الحرفة: ${craftsman.category}', style: TextStyle(color: Colors.white70)),
                      Text('الإتاحة: ${craftsman.isAvailable ? 'متاح' : 'غير متاح'}',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}