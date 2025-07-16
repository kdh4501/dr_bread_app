// lib/features/recipe/presentation/bloc/review_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

abstract class ReviewState extends Equatable {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? errorMessage;

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [reviews, isLoading, errorMessage];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {
  const ReviewLoading({
    required super.reviews,
  }) : super(isLoading: true);
}

class ReviewLoaded extends ReviewState {
  const ReviewLoaded({
    required super.reviews,
  }) : super(isLoading: false);
}

class ReviewError extends ReviewState {
  const ReviewError({
    required super.errorMessage,
    required super.reviews,
  }) : super(isLoading: false);
}
