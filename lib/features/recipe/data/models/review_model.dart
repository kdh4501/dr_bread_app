// lib/features/recipe/data/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewModel {
  final String uid;
  final String recipeId;
  final String authorUid;
  final String? authorDisplayName;
  final String? authorPhotoUrl;
  final double rating;
  final String reviewText;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  ReviewModel({
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

  factory ReviewModel.fromJson(Map<String, dynamic> json, String uid) {
    return ReviewModel(
      uid: uid,
      recipeId: json['recipeId'] as String,
      authorUid: json['authorUid'] as String,
      authorDisplayName: json['authorDisplayName'] as String?,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      rating: (json['rating'] as num).toDouble(), // Firestore는 double 대신 num으로 저장될 수 있음
      reviewText: json['reviewText'] as String,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'authorPhotoUrl': authorPhotoUrl,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      uid: uid,
      recipeId: recipeId,
      authorUid: authorUid,
      authorDisplayName: authorDisplayName,
      authorPhotoUrl: authorPhotoUrl,
      rating: rating,
      reviewText: reviewText,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      uid: entity.uid,
      recipeId: entity.recipeId,
      authorUid: entity.authorUid,
      authorDisplayName: entity.authorDisplayName,
      authorPhotoUrl: entity.authorPhotoUrl,
      rating: entity.rating,
      reviewText: entity.reviewText,
      createdAt: Timestamp.fromDate(entity.createdAt),
      updatedAt: entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
    );
  }
}