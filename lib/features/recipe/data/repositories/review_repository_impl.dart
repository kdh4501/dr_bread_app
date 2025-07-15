
// lib/features/recipe/data/repositories/review_repository_impl.dart
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/firestore_review_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirestoreReviewDataSource dataSource;
  ReviewRepositoryImpl(this.dataSource);

  @override
  Future<String> addReview(ReviewEntity review) async {
    final reviewModel = ReviewModel.fromEntity(review);
    return await dataSource.addReview(reviewModel);
  }

  @override
  Stream<List<ReviewEntity>> getReviewsForRecipe(String recipeId) {
    return dataSource.getReviewsForRecipe(recipeId).map((reviewModels) {
      return reviewModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await dataSource.deleteReview(reviewId);
  }
}