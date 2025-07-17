// lib/features/recipe/presentation/bloc/review_bloc.dart
import 'package:bloc/bloc.dart';
import 'dart:async';
import '../../domain/usecases/add_review_usecase.dart';
import '../../domain/usecases/get_reviews_for_recipe_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/update_review_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final AddReviewUseCase _addReviewUseCase;
  final GetReviewsForRecipeUseCase _getReviewsForRecipeUseCase;
  final DeleteReviewUseCase _deleteReviewUseCase;
  final UpdateReviewUseCase _updateReviewUseCase;

  ReviewBloc(
      this._addReviewUseCase,
      this._getReviewsForRecipeUseCase,
      this._deleteReviewUseCase,
      this._updateReviewUseCase,
      ) : super(ReviewInitial()) {
    on<GetReviews>(_onGetReviews);
    on<AddReview>(_onAddReview);
    on<DeleteReview>(_onDeleteReview);
    on<UpdateReview>(_onUpdateReview);
  }

  Future<void> _onGetReviews(GetReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading(reviews: state.reviews));
    try {
      final reviewStream = _getReviewsForRecipeUseCase(event.recipeId);

      await emit.onEach( // await 키워드를 사용하여 스트림이 완료될 때까지 기다림
        reviewStream, // 구독할 스트림
        onData: (reviews) { // 스트림에서 새로운 데이터가 발행될 때마다 호출
          emit(ReviewLoaded(reviews: reviews));
        },
        onError: (error, stackTrace) { // 스트림에서 에러 발생 시 호출
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

  Future<void> _onUpdateReview(UpdateReview event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading(reviews: state.reviews));
    try {
      await _updateReviewUseCase(event.review);
      // 업데이트된 리뷰를 기존 목록에서 찾아 교체
      final updatedReviews = state.reviews.map((r) =>
      r.uid == event.review.uid ? event.review : r).toList();
      emit(ReviewLoaded(reviews: updatedReviews));
      // Cloud Function이 자동으로 통계를 업데이트할 것임
    } catch (e) {
      emit(ReviewError(errorMessage: '리뷰 수정 실패: ${e.toString()}', reviews: state.reviews));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}