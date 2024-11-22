import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herafi/data/repositroies/availabilityRepositoryImpl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:herafi/data/remotDataSource/availabilityRemoteDataSource.dart';
import 'package:herafi/domain/entites/availability.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  bool isSimpleStatus = true;
  bool isAvailable = true;
  bool receiveOffersOffline = false;
  String unavailabilityReason = '';
  List<String> selectedDays = [];

  late final AvailabilityRepositoryImpl availabilityRepository;

  @override
  void initState() {
    super.initState();
    availabilityRepository = AvailabilityRepositoryImpl(
      AvailabilityRemoteDataSource(Supabase.instance.client, FirebaseAuth.instance),
    );
  }

  /// Function to toggle selected days for schedule status
  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  /// Function to save availability data to Supabase
  Future<void> saveAvailability() async {
    final craftsmanId = FirebaseAuth.instance.currentUser?.uid ?? 'craftsman_1';

    try {
      if (isSimpleStatus) {
        // Insert simple status availability
        final simpleAvailability = AvailabilityEntity(
          id: 0, // Supabase will auto-generate the ID
          craftsmanId: craftsmanId,
          availabilityType: 'simple',
          dayOfWeek: null,
          available: isAvailable,
          unavailabilityReason: isAvailable ? null : unavailabilityReason,
          receiveOffersOffline: receiveOffersOffline,
        );
        await availabilityRepository.addAvailability(simpleAvailability);
      } else {
        // Insert schedule status availability
        for (final day in ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']) {
          final isSelected = selectedDays.contains(day);
          final scheduleAvailability = AvailabilityEntity(
            id: 0, // Supabase will auto-generate the ID
            craftsmanId: craftsmanId,
            availabilityType: 'schedule',
            dayOfWeek: day,
            available: isSelected,
            unavailabilityReason: null, // Not applicable for schedule
            receiveOffersOffline: receiveOffersOffline,
          );
          await availabilityRepository.addAvailability(scheduleAvailability);
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Availability saved successfully!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving availability: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Availability"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple status radio button
            RadioListTile(
              title: Text("Simple status", style: TextStyle(fontSize: 18)),
              value: true,
              groupValue: isSimpleStatus,
              onChanged: (bool? value) {
                setState(() {
                  isSimpleStatus = value ?? true;
                });
              },
            ),
            if (isSimpleStatus) ...[
              // Simple status availability toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Available", style: TextStyle(fontSize: 18)),
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
              // Unavailability reason text field (shown if not available)
              if (!isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        unavailabilityReason = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Reason for unavailability",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
            SizedBox(height: 20),

            // Schedule status radio button
            RadioListTile(
              title: Text("Schedule status", style: TextStyle(fontSize: 18)),
              value: false,
              groupValue: isSimpleStatus,
              onChanged: (bool? value) {
                setState(() {
                  isSimpleStatus = value ?? false;
                });
              },
            ),
            if (!isSimpleStatus)
            // Day selection for schedule status
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
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            SizedBox(height: 20),

            // Receive offers offline toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Receive offers offline", style: TextStyle(fontSize: 18)),
                Switch(
                  value: receiveOffersOffline,
                  onChanged: (bool value) {
                    setState(() {
                      receiveOffersOffline = value;
                    });
                  },
                ),
              ],
            ),

            Spacer(),

            // Save button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: saveAvailability, // Call save function on press
                child: Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
