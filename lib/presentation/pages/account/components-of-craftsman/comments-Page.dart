import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsPage extends StatelessWidget {
  final String craftsmanId;

  const CommentsPage({Key? key, required this.craftsmanId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('ratings')
            .select('''
              comment, 
              customer_id, 
              work_perfection, 
              behavior, 
              respect_deadlines, 
              customer (
                id, 
                users (
                  name, 
                  image
                )
              )
            ''')
            .eq('craftsman_id', craftsmanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ratings = snapshot.data as List?;
          if (ratings == null || ratings.isEmpty) {
            return const Center(
              child: Text(
                'No ratings available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              final customer = rating['customer'];
              final user = customer != null ? customer['users'] : null;

              final averageRating = ((rating['work_perfection'] ?? 0) +
                  (rating['behavior'] ?? 0) +
                  (rating['respect_deadlines'] ?? 0)) /
                  3;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.black87,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user != null &&
                            user['image'] != null &&
                            user['image'].isNotEmpty
                            ? NetworkImage(user['image'])
                            : null,
                        child: user == null ||
                            user['image'] == null ||
                            user['image'].isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? user['name'] ?? 'Unknown' : 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < averageRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // تفاصيل التقييم
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Perfect work:',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < (rating['work_perfection'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Respect deadlines:',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < (rating['respect_deadlines'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Behavior:',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < (rating['behavior'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // الكومنت إذا كان موجودًا
                          if (rating['comment'] != null && rating['comment'] != '')
                            Text(
                              rating['comment'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}