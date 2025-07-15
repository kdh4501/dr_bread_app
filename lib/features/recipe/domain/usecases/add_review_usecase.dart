// lib/features/recipe/domain/usecases/add_review_usecase.dart
import '../entities/review.dart';
import '../repositories/review_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart'; // AuthRepository 임포트

class AddReviewUseCase {
  final ReviewRepository reviewRepository;
  final AuthRepository authRepository; // 작성자 정보 가져오기용
  AddReviewUseCase(this.reviewRepository, this.authRepository);

  Future<String> call(ReviewEntity review) async {
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('로그인된 사용자만 리뷰를 작성할 수 있습니다.');
    }
    final reviewWithAuthor = review.copyWith(
      authorUid: currentUser.uid,
      authorDisplayName: currentUser.displayName,
      authorPhotoUrl: currentUser.photoUrl,
      createdAt: DateTime.now(),
    );
    return await reviewRepository.addReview(reviewWithAuthor);
  }
}