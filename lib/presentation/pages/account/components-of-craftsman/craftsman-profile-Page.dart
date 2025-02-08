import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:herafi/data/models/WorkModel.dart';
import 'package:herafi/data/models/availabilityModel.dart';
import 'package:herafi/data/models/certificateModel.dart';
import 'package:herafi/data/repositroies/userRepositoryImp.dart';
import 'package:herafi/domain/entites/availability.dart';
import 'package:herafi/domain/entites/certificate.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:herafi/domain/entites/user.dart';
import 'package:herafi/domain/entites/work.dart';
import 'package:herafi/domain/usecases/chatUseCases/fetchUserData.dart';
import 'package:herafi/presentation/Widgets/leadingAppBar.dart';
import 'package:herafi/presentation/controllers/crossDataContoller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../domain/entites/chat.dart';
import '../../../routes/app_routes.dart';
import 'comments-Page.dart';

class CraftsmanProfilePage extends StatefulWidget {
  final String craftsmanId;
  final UserEntity? user;
  const CraftsmanProfilePage({Key? key, required this.craftsmanId,this.user}) : super(key: key);

  @override
  _CraftsmanProfilePageState createState() => _CraftsmanProfilePageState();
}

class _CraftsmanProfilePageState extends State<CraftsmanProfilePage> {
  late UserEntity user;
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
    try {
      setState(() => isLoading = true);
      if(widget.user!=null){
        user=widget.user!;
      }
      else{
        final result=await fetchUserDataUseCase(userRepos: userRepositoryImp()).call(userId: craftsmanId);
        result.fold((ifLeft){}, (ifRight){
          user=ifRight!;
        });
      }
      final ratingsResponse = await Supabase.instance.client
          .from('ratings')
          .select('work_perfection, behavior, respect_deadlines')
          .eq('craftsman_id', craftsmanId);
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
                3);

            totalStars += overallRating;
            starCounts[overallRating] = (starCounts[overallRating] ?? 0) + 1;
          }
        }

        averageRating =
        totalRatings > 0 ? totalStars / totalRatings : 0.0;
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
        SnackBar(content: Text('خطأ أثناء تحميل البيانات: $e')),
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
          title: const Text('الملف الشخصي'),
          leading: leadingAppBar(),
        ),
        body: Column(
          children: [
            _buildCraftsmanInfoSection(isCraftsmanViewingOwnProfile),
            _buildRatingSection(),
            const Divider(),
             TabBar(
              labelColor: Theme.of(context).focusColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'الشهادات'),
                Tab(text: 'الأعمال'),
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
    return availability.any((entry) =>
    entry.available &&
        (entry.availabilityType == 'simple' ||
            (entry.availabilityType == 'schedule' && entry.dayOfWeek != null)));
  }

  Widget _buildCraftsmanInfoSection(bool isCraftsmanViewingOwnProfile) {
    final isAvailable = isCraftsmanAvailable();

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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(user.image),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text((user as CraftsmanEntity).category),
                      Text(user.location),
                    ],
                  ),
                ],
              ),
              IconButton(onPressed: (){
                  List<chatEntity> chats=Get.find<crossData>().chats;
                  chatEntity chat=chatEntity(user: user, lastMessage:null, missedMessagesCountByMe: 0, missedMessagesCountByOther: 0, documentId: '');
                  chats.forEach((item){
                    if(item.user.id==user.id){
                      chat=item;
                    }
                  });
                  Get.toNamed(AppRoutes.chatpage,arguments: chat);

              }, icon: Icon(Icons.chat))
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
                    isAvailable ? 'أنا متاح للعمل' : 'أنا غير متاح',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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

  Widget _buildCertificatesSection() {
    return certificates.isEmpty
        ? const Center(child: Text('لا توجد شهادات متاحة.'))
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
          child: CachedNetworkImage(
            imageUrl:certificates[index].image ?? '',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildWorksSection() {
    return works.isEmpty
        ? const Center(child: Text('لا توجد أعمال متاحة.'))
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
                  child: CachedNetworkImage(
                    imageUrl:works[index].image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  color: Colors.grey,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    works[index].title,
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
                      "لا توجد صورة متاحة",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  "العنوان:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(work.title ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Text(
                  "الوصف:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(work.description ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
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
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('الأيام المتاحة',style: TextStyle(color: Colors.white),),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              'الأحد',
              'الإثنين',
              'الثلاثاء',
              'الأربعاء',
              'الخميس',
              'الجمعة',
              'السبت',
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
              child: const Text('إغلاق'),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating.ceil()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(5, (index) {
                int star = 5 - index;
                double totalRatings =
                starCounts.values.fold(0, (a, b) => a + b).toDouble();
                double percentage = totalRatings > 0
                    ? (starCounts[star]?.toDouble() ?? 0) / totalRatings
                    : 0.0;

                return Row(
                  children: [
                    Text('$star'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${starCounts[star] ?? 0}'),
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
                  'عرض التعليقات',
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
  void _showUnavailabilityReason(String? reason) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('سبب عدم التوفر:',style: TextStyle(color: Colors.white),),
          content: Text(
            reason?.isNotEmpty == true ? reason! : 'لم يتم توفير سبب.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

}
