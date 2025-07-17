// lib/features/recipe/presentation/bloc/review_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class GetReviews extends ReviewEvent {
  final String recipeId;
  const GetReviews(this.recipeId);
  @override
  List<Object?> get props => [recipeId];
}

class AddReview extends ReviewEvent {
  final ReviewEntity review;
  const AddReview(this.review);
  @override
  List<Object?> get props => [review];
}

class DeleteReview extends ReviewEvent {
  final String reviewId;
  const DeleteReview(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class UpdateReview extends ReviewEvent {
  final ReviewEntity review; // 수정할 리뷰 (UID 포함)
  const UpdateReview(this.review);
  @override
  List<Object?> get props => [review];
}