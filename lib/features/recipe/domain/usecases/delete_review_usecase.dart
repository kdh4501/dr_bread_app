// lib/features/recipe/domain/usecases/delete_review_usecase.dart
import '../repositories/review_repository.dart';

class DeleteReviewUseCase {
  final ReviewRepository repository;
  DeleteReviewUseCase(this.repository);

  Future<void> call(String reviewId) async {
    await repository.deleteReview(reviewId);
  }
}