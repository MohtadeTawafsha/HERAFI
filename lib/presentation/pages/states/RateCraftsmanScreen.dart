import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RateCraftsmanScreen extends StatefulWidget {
  final String craftsmanId;
  final int projectId;

  const RateCraftsmanScreen({Key? key, required this.craftsmanId,required this.projectId}) : super(key: key);

  @override
  _RateCraftsmanScreenState createState() => _RateCraftsmanScreenState();
}

class _RateCraftsmanScreenState extends State<RateCraftsmanScreen> {
  double workPerfectionRating = 0;
  double behaviorRating = 0;
  double respectDeadlinesRating = 0;
  final TextEditingController commentController = TextEditingController();

  String _userId = FirebaseAuth.instance.currentUser!.uid;

  final SupabaseClient supabaseClient = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
  }
  Future<void> submitRating() async {

    try {
      final ratingData = {
        'craftsman_id': widget.craftsmanId,
        'customer_id': _userId,
        'project_id': widget.projectId,
        'work_perfection': workPerfectionRating.toInt(),
        'behavior': behaviorRating.toInt(),
        'respect_deadlines': respectDeadlinesRating.toInt(),
        'comment': commentController.text,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient.from('ratings').insert(ratingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال التقييم بنجاح!')),
      );
      Get.back(result: true);
    } catch (e) {
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال التقييم!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الحرفي'),
        leading: leadingAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            // اسم الحرفي
            Text(
              "تقييم الحرفي",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // التقييم بالنجوم
            buildRatingRow(
              'إتقان العمل',
              workPerfectionRating,
                  (rating) {
                setState(() {
                  workPerfectionRating = rating;
                });
              },
            ),
            buildRatingRow(
              'السلوك',
              behaviorRating,
                  (rating) {
                setState(() {
                  behaviorRating = rating;
                });
              },
            ),
            buildRatingRow(
              'احترام المواعيد',
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
                labelText: 'التعليق',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // زر الإرسال
            TextButton(
              onPressed: submitRating,
              child: const Text(
                'إرسال',
                style: TextStyle(fontSize: 16),
              ),
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
                    onRatingChanged(index + 1.0);
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
