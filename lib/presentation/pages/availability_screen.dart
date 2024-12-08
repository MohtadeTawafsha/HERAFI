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
  bool isAvailable = true; // For Simple Status
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

  /// Load existing availability data
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
            SnackBar(content: Text('Error loading availability: ${failure.message}')),
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
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Save availability data
  Future<void> saveAvailability() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid;

    if (craftsmanId == null || craftsmanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
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
            SnackBar(content: Text('Error fetching availability: ${failure.message}')),
          );
        },
        (availabilityList) async {
          if (availabilityList.isNotEmpty) {
            // Update existing record
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
            // Insert new record
            if (isSimpleStatus) {
              final newAvailability = AvailabilityEntity(
                id: 0,
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
                id: 0,
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
        const SnackBar(content: Text('Availability saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving availability: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Toggle selected days for schedule status
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
        title: const Text("Availability"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple Status
                  RadioListTile(
                    title: const Text("Simple status", style: TextStyle(fontSize: 18)),
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
                        const Text("Available", style: TextStyle(fontSize: 18)),
                        Switch(
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
                            labelText: "Reason for unavailability",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 20),

                  // Schedule Status
                  RadioListTile(
                    title: const Text("Schedule status", style: TextStyle(fontSize: 18)),
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
                        'Sunday',
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday'
                      ].map((day) {
                        final isSelected = selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => toggleDay(day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const Spacer(),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: saveAvailability,
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
