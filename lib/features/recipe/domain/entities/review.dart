// lib/features/recipe/domain/entities/review.dart
import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String uid; // 리뷰 ID (Firestore 문서 ID)
  final String recipeId; // 어떤 레시피에 대한 리뷰인지
  final String authorUid; // 리뷰 작성자 UID
  final String? authorDisplayName; // 리뷰 작성자 닉네임 (캐싱용)
  final String? authorPhotoUrl; // 리뷰 작성자 프로필 사진 (캐싱용)
  final double rating; // 평점 (1.0 ~ 5.0)
  final String reviewText; // 리뷰 내용
  final DateTime createdAt; // 작성 시간
  final DateTime? updatedAt; // 수정 시간

  const ReviewEntity({
    required this.uid,
    required this.recipeId,
    required this.authorUid,
    this.authorDisplayName,
    this.authorPhotoUrl,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    this.updatedAt,
  });

  ReviewEntity copyWith({
    String? uid,
    String? recipeId,
    String? authorUid,
    String? authorDisplayName,
    String? authorPhotoUrl,
    double? rating,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      uid: uid ?? this.uid,
      recipeId: recipeId ?? this.recipeId,
      authorUid: authorUid ?? this.authorUid,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    recipeId,
    authorUid,
    authorDisplayName,
    authorPhotoUrl,
    rating,
    reviewText,
    createdAt,
    updatedAt,
  ];
}