// lib/features/recipe/domain/usecases/update_review_usecase.dart
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class UpdateReviewUseCase {
  final ReviewRepository repository;
  UpdateReviewUseCase(this.repository);

  Future<void> call(ReviewEntity review) async {
    // 수정 시에는 authorUid 등은 건드리지 않음
    final updatedReview = review.copyWith(
      updatedAt: DateTime.now(), // 수정 시간 기록
    );
    await repository.updateReview(updatedReview);
  }
}