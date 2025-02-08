import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/remotDataSource/craftsmanRemotDataSource.dart';
import 'package:herafi/data/remotDataSource/ratingRemoteDataSource.dart';
import 'package:herafi/domain/entites/RatingEntity.dart';
import 'dart:developer';

extension MapExtensions on Map<String, dynamic> {
  String get id => this['id']?.toString() ?? '';
}

class RecommendationService {
  final CraftsmanRemoteDataSource craftsmanRemoteDataSource;
  final RatingRemoteDataSource ratingRemoteDataSource;

  RecommendationService(this.craftsmanRemoteDataSource, this.ratingRemoteDataSource);

  Future<Object> getTopCraftsmen(String customerId) async {
    try {
      log("Fetching all craftsmen...");
      final craftsmanList = await craftsmanRemoteDataSource.fetchAllCraftsmen();
      log("Craftsmen list fetched: ${craftsmanList.length} craftsmen found");

      if (craftsmanList.isEmpty) {
        log("No craftsmen found in the database");
        return Left(DatabaseFailure("No craftsmen found"));
      }

      // Fetch all ratings
      Map<String, List<RatingEntity>> craftsmanRatings = {};
      for (var craftsman in craftsmanList) {
        log("Fetching ratings for craftsman ID: ${craftsman.id}");
        final ratingsResult = await ratingRemoteDataSource.fetchRatingsByCraftsman(craftsman.id);
        craftsmanRatings[craftsman.id] = await Future.wait(ratingsResult.map((rating) async => await rating.toEntity()));
        log("Ratings fetched for craftsman ${craftsman.id}: ${ratingsResult.length} ratings found");
      }

      // Fetch customer ratings
      log("Fetching ratings given by customer ID: $customerId");
      final customerRatings = await ratingRemoteDataSource.fetchRatingsByCustomer(customerId);
      final customerEntities = await Future.wait(customerRatings.map((rating) async => await rating.toEntity()));
      log("Customer ratings fetched: ${customerEntities.length} ratings found");

      // Collaborative filtering: Compute similarity scores between customers
      Map<String, double> customerSimilarityScores = {};
      for (var craftsman in craftsmanList) {
        double similarityScore = 0;
        if (craftsmanRatings.containsKey(craftsman.id)) {
          final ratings = craftsmanRatings[craftsman.id]!;
          for (var rating in ratings) {
            if (customerEntities.any((r) => r.customerId == rating.customerId)) {
              similarityScore += (rating.workPerfection * 0.5) + (rating.behavior * 0.3) + (rating.respectDeadlines * 0.2);
            }
          }
        }
        customerSimilarityScores[craftsman.id] = similarityScore;
        log("Craftsman ${craftsman.id} similarity score: $similarityScore");
      }

      // Sort craftsmen based on similarity score (descending order)
      craftsmanList.sort((a, b) => (customerSimilarityScores[b.id] ?? 0).compareTo(customerSimilarityScores[a.id] ?? 0));

      // Get the top 5 recommended craftsmen
      final topCraftsmen = craftsmanList.take(5).toList();
      log("Top 5 recommended craftsmen: ${topCraftsmen.map((c) => c.id).toList()}");
      return topCraftsmen;
    } catch (e, stacktrace) {
      log("Exception occurred: $e", error: e, stackTrace: stacktrace);
      return DatabaseFailure(e.toString());
    }
  }
}
