// lib/features/recipe/presentation/bloc/review_bloc.dart
import 'package:bloc/bloc.dart';
import 'dart:async';
import '../../domain/usecases/add_review_usecase.dart';
import '../../domain/usecases/get_reviews_for_recipe_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final AddReviewUseCase _addReviewUseCase;
  final GetReviewsForRecipeUseCase _getReviewsForRecipeUseCase;
  final DeleteReviewUseCase _deleteReviewUseCase;

  StreamSubscription? _reviewsSubscription;

  ReviewBloc(
      this._addReviewUseCase,
      this._getReviewsForRecipeUseCase,
      this._deleteReviewUseCase,
      ) : super(ReviewInitial()) {
    on<GetReviews>(_onGetReviews);
    on<AddReview>(_onAddReview);
    on<DeleteReview>(_onDeleteReview);
  }

  Future<void> _onGetReviews(GetReviews event, Emitter<ReviewState> emit) async {
    _reviewsSubscription?.cancel(); // 이전 구독 취소
    emit(ReviewLoading(reviews: state.reviews));
    try {
      final reviewStream = _getReviewsForRecipeUseCase(event.recipeId);
      _reviewsSubscription = reviewStream.listen(
            (reviews) {
          emit(ReviewLoaded(reviews: reviews));
        },
        onError: (error, stackTrace) {
          emit(ReviewError(errorMessage: '리뷰를 불러오는데 실패했습니다: $error', reviews: state.reviews));
        },
      );
    } catch (e) {
      emit(ReviewError(errorMessage: '리뷰 로딩 중 에러 발생: $e', reviews: state.reviews));
    }
  }

  Future<void> _onAddReview(AddReview event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading(reviews: state.reviews)); // 리뷰 추가 중 로딩 상태
    try {
      await _addReviewUseCase(event.review);
      // 성공 후 다시 리뷰 목록을 가져오도록 GetReviews 이벤트 추가
      add(GetReviews(event.review.recipeId));
      // 또는 emit(ReviewLoaded(reviews: state.reviews)); // 실제 데이터를 다시 가져오는 것이 더 정확
    } catch (e) {
      emit(ReviewError(errorMessage: '리뷰 작성 실패: ${e.toString()}', reviews: state.reviews));
    }
  }

  Future<void> _onDeleteReview(DeleteReview event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading(reviews: state.reviews)); // 리뷰 삭제 중 로딩 상태
    try {
      await _deleteReviewUseCase(event.reviewId);
      // 성공 후 다시 리뷰 목록을 가져오도록 GetReviews 이벤트 추가
      // 삭제된 리뷰를 제외한 새로운 목록을 발행
      final updatedReviews = state.reviews.where((review) => review.uid != event.reviewId).toList();
      emit(ReviewLoaded(reviews: updatedReviews));
    } catch (e) {
      emit(ReviewError(errorMessage: '리뷰 삭제 실패: ${e.toString()}', reviews: state.reviews));
    }
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    return super.close();
  }
}