import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:herafi/data/remotDataSource/availabilityRemoteDataSource.dart';
import 'package:herafi/data/repositroies/availabilityRepositoryImpl.dart';
import 'package:herafi/domain/entites/availability.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  bool isSimpleStatus = true; // Default status
  bool isAvailable = false; // For Simple Status
  String unavailabilityReason = ''; // Reason for Not Available
  List<String> selectedDays = []; // For Schedule Status
  bool isLoading = false; // Loading Indicator

  late final AvailabilityRepositoryImpl availabilityRepository;

  @override
  void initState() {
    super.initState();
    availabilityRepository = AvailabilityRepositoryImpl(
      AvailabilityRemoteDataSource(Supabase.instance.client, FirebaseAuth.instance),
    );
    _loadAvailabilityData();
  }

  Future<void> _loadAvailabilityData() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;
    if (craftsmanId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final availabilityResult = await availabilityRepository.fetchAvailability(craftsmanId);

      availabilityResult.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل التوافر: ${failure.message}')),
          );
        },
            (availabilityList) {
          if (availabilityList.isNotEmpty) {
            final data = availabilityList.first;

            if (data.availabilityType == 'simple') {
              setState(() {
                isSimpleStatus = true;
                isAvailable = data.available;
                unavailabilityReason = data.unavailabilityReason ?? '';
              });
            } else if (data.availabilityType == 'schedule') {
              setState(() {
                isSimpleStatus = false;
                selectedDays = data.dayOfWeek?.split(',') ?? [];
              });
            }
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveAvailability() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null || craftsmanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: المستخدم غير مسجل الدخول.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final availabilityResult = await availabilityRepository.fetchAvailability(craftsmanId);

      availabilityResult.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في جلب التوافر: ${failure.message}')),
          );
        },
            (availabilityList) async {
          if (availabilityList.isNotEmpty) {
            final existingRecord = availabilityList.first;

            if (isSimpleStatus) {
              final updatedAvailability = AvailabilityEntity(
                id: existingRecord.id,
                craftsmanId: craftsmanId,
                availabilityType: 'simple',
                dayOfWeek: null,
                available: isAvailable,
                unavailabilityReason: isAvailable ? null : unavailabilityReason,
              );
              await availabilityRepository.updateAvailability(updatedAvailability);
            } else {
              final selectedDaysString = selectedDays.join(',');
              final updatedAvailability = AvailabilityEntity(
                id: existingRecord.id,
                craftsmanId: craftsmanId,
                availabilityType: 'schedule',
                dayOfWeek: selectedDaysString,
                available: true,
                unavailabilityReason: null,
              );
              await availabilityRepository.updateAvailability(updatedAvailability);
            }
          } else {
            if (isSimpleStatus) {
              final newAvailability = AvailabilityEntity(
                id: null,
                craftsmanId: craftsmanId,
                availabilityType: 'simple',
                dayOfWeek: null,
                available: isAvailable,
                unavailabilityReason: isAvailable ? null : unavailabilityReason,
              );
              await availabilityRepository.addAvailability(newAvailability);
            } else {
              final selectedDaysString = selectedDays.join(',');
              final newAvailability = AvailabilityEntity(
                id: null,
                craftsmanId: craftsmanId,
                availabilityType: 'schedule',
                dayOfWeek: selectedDaysString,
                available: true,
                unavailabilityReason: null,
              );
              await availabilityRepository.addAvailability(newAvailability);
            }
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التوافر بنجاح!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حفظ التوافر: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التوافر"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile(
              title: const Text("الحالة البسيطة", style: TextStyle(fontSize: 18)),
              value: true,
              groupValue: isSimpleStatus,
              onChanged: (bool? value) {
                setState(() {
                  isSimpleStatus = value ?? true;
                });
              },
            ),
            if (isSimpleStatus) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("متاح", style: TextStyle(fontSize: 18)),
                  Switch(
                    activeColor: Theme.of(context).focusColor,
                    value: isAvailable,
                    onChanged: (bool value) {
                      setState(() {
                        isAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              if (!isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        unavailabilityReason = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "سبب عدم التوفر",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            RadioListTile(
              title: const Text("الحالة المجدولة", style: TextStyle(fontSize: 18)),
              value: false,
              groupValue: isSimpleStatus,
              onChanged: (bool? value) {
                setState(() {
                  isSimpleStatus = value ?? false;
                });
              },
            ),
            if (!isSimpleStatus)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  'الأحد',
                  'الإثنين',
                  'الثلاثاء',
                  'الأربعاء',
                  'الخميس',
                  'الجمعة',
                  'السبت'
                ].map((day) {
                  final isSelected = selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => toggleDay(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).focusColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color:  Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 32,),
            Center(
              child: TextButton(
                onPressed: saveAvailability,
                child: const Text("حفظ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
