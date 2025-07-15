// lib/features/recipe/domain/repositories/review_repository.dart
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<String> addReview(ReviewEntity review);
  Stream<List<ReviewEntity>> getReviewsForRecipe(String recipeId);
  Future<void> deleteReview(String reviewId);
}