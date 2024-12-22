import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RateCraftsmanScreen extends StatefulWidget {
  final String craftsmanId;

  const RateCraftsmanScreen({Key? key, required this.craftsmanId}) : super(key: key);

  @override
  _RateCraftsmanScreenState createState() => _RateCraftsmanScreenState();
}

class _RateCraftsmanScreenState extends State<RateCraftsmanScreen> {
  double workPerfectionRating = 0;
  double behaviorRating = 0;
  double respectDeadlinesRating = 0;
  final TextEditingController commentController = TextEditingController();

  String _userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // ID الخاص بالكستمر
  String craftsmanName = "Loading..."; // اسم الحرفي
  String craftsmanImage = ""; // صورة الحرفي
  int? projectId; // ID الخاص بالمشروع
  bool isLoading = true;

  final SupabaseClient supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchCraftsmanData(); // جلب بيانات الحرفي
    _fetchProjectId(); // جلب ID المشروع
  }

  Future<void> _fetchCraftsmanData() async {
    try {
      setState(() => isLoading = true);

      // جلب بيانات المستخدم
      final userResponse = await supabaseClient
          .from('users')
          .select('name, image')
          .eq('id', widget.craftsmanId)
          .single();

      if (userResponse != null) {
        setState(() {
          craftsmanName = userResponse['name'] ?? "Unknown";
          craftsmanImage = userResponse['image'] ?? "";
        });
      } else {
        setState(() {
          craftsmanName = "Craftsman not found";
        });
      }
    } catch (e) {
      print("Error fetching craftsman data: $e");
      setState(() {
        craftsmanName = "Error loading name";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchProjectId() async {
    try {
      // جلب ID المشروع بناءً على customer_id و craftsman_id
      final projectResponse = await supabaseClient
          .from('projects')
          .select('id')
          .eq('customer_id', _userId)
          .eq('craftsman_id', widget.craftsmanId)
          .order('start_date', ascending: false) // ترتيب حسب أحدث مشروع
          .limit(1)
          .single();

      if (projectResponse != null) {
        setState(() {
          projectId = projectResponse['id'];
        });
        print("Project ID: $projectId");
      } else {
        print("No project found for this customer and craftsman.");
      }
    } catch (e) {
      print("Error fetching project ID: $e");
    }
  }

  Future<void> submitRating() async {
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No associated project found for this craftsman and customer.')),
      );
      return;
    }

    try {
      final ratingData = {
        'craftsman_id': widget.craftsmanId,
        'customer_id': _userId,
        'project_id': projectId,
        'work_perfection': workPerfectionRating.toInt(),
        'behavior': behaviorRating.toInt(),
        'respect_deadlines': respectDeadlinesRating.toInt(),
        'comment': commentController.text,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabaseClient.from('ratings').insert(ratingData);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully!')),
        );
      }
    } catch (e) {
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Craftsman'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة الحرفي
            craftsmanImage.isNotEmpty
                ? CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(craftsmanImage),
              onBackgroundImageError: (exception, stackTrace) {
                print("Error loading image: $exception");
              },
            )
                : const Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            // اسم الحرفي
            Text(
              craftsmanName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // التقييم بالنجوم
            buildRatingRow(
              'Work Perfection',
              workPerfectionRating,
                  (rating) {
                setState(() {
                  workPerfectionRating = rating;
                });
              },
            ),
            buildRatingRow(
              'Behavior',
              behaviorRating,
                  (rating) {
                setState(() {
                  behaviorRating = rating;
                });
              },
            ),
            buildRatingRow(
              'Respect Deadlines',
              respectDeadlinesRating,
                  (rating) {
                setState(() {
                  respectDeadlinesRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            // حقل إدخال التعليق
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // زر الإرسال
            ElevatedButton(
              onPressed: () {
                submitRating();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRatingRow(String title, double rating, Function(double) onRatingChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    onRatingChanged(index + 1.0); // تحديث التقييم عند الضغط
                  },
                  child: Icon(
                    Icons.star,
                    size: 30,
                    color: (index < rating) ? Colors.amber : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}