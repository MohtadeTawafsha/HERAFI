import 'package:flutter/material.dart';
import 'package:herafi/data/remotDataSource/craftsmanRemotDataSource.dart';
import 'package:herafi/data/remotDataSource/ratingRemoteDataSource.dart';
import 'package:herafi/domain/entites/craftsman.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:herafi/core/status/error/Failure.dart';
import 'dart:developer';

import '../../../data/remotDataSource/recommendationServise.dart';

class RecommendationPage extends StatefulWidget {
  final RecommendationService recommendationService;

  RecommendationPage({required this.recommendationService});

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  List<CraftsmanEntity> recommendedCraftsmen = [];
  bool isLoading = false;
  String? errorMessage;

  void fetchRecommendations(String customerId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      recommendedCraftsmen.clear(); // Clear previous results to refresh UI
    });

    try {
      log("Fetching recommendations for customer ID: $customerId");
      final result = await widget.recommendationService.getTopCraftsmen(customerId);
      log("Result received: $result");

      if (result is List<CraftsmanEntity>) { // ✅ Fix: Ensure it's a valid list
        setState(() {
          recommendedCraftsmen = result;
          isLoading = false;
        });
        log("Updated recommendedCraftsmen list size: ${recommendedCraftsmen.length}");
      } else if (result is Either<Failure, List<CraftsmanEntity>>) {
        result.fold((failure) {
          setState(() {
            errorMessage = "Error: ${failure.toString()}";
            isLoading = false;
          });
          log("Error: ${failure.toString()}");
        }, (craftsmen) {
          setState(() {
            recommendedCraftsmen = craftsmen;
            isLoading = false;
          });
          log("Updated recommendedCraftsmen list size: ${recommendedCraftsmen.length}");
        });
      } else {
        setState(() {
          errorMessage = "Unexpected error occurred";
          isLoading = false;
        });
        log("Unexpected error: $result");
      }
    } catch (e, stacktrace) {
      setState(() {
        errorMessage = "Exception: $e";
        isLoading = false;
      });
      log("Exception: $e", error: e, stackTrace: stacktrace);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommended Craftsmen')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Enter Customer ID'),
              onSubmitted: (value) {
                log("TextField submitted with value: $value");
                fetchRecommendations(value);
              },
            ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold))
            else if (recommendedCraftsmen.isEmpty)
                Text(
                  "No recommended craftsmen found.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                )
              else
                Expanded(
                  child: Container(
                    color: Colors.blue.withOpacity(0.1),
                    child: ListView.builder(
                      itemCount: recommendedCraftsmen.length,
                      itemBuilder: (context, index) {
                        final craftsman = recommendedCraftsmen[index];
                        log("Displaying recommended craftsman: ${craftsman.name}");

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: ListTile(
                            leading: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                            title: Text(
                              craftsman.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${craftsman.category} - ${craftsman.yearsOfExp} years experience'),
                                Text('Location: ${craftsman.location}', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )

          ],
        ),
      ),


    );
  }
}
