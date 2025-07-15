// lib/features/recipe/data/datasources/firestore_review_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/review_model.dart'; // ReviewModel 임포트

class FirestoreReviewDataSource {
  final FirebaseFirestore _firestore;
  FirestoreReviewDataSource(this._firestore);
  final CollectionReference _reviewsCollection = FirebaseFirestore.instance.collection('reviews');

  // 리뷰 추가
  Future<String> addReview(ReviewModel review) async {
    final docRef = await _reviewsCollection.add(review.toJson());
    return docRef.id;
  }

  // 특정 레시피의 리뷰 목록 조회 (실시간 스트림)
  Stream<List<ReviewModel>> getReviewsForRecipe(String recipeId) {
    return _reviewsCollection
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true) // 최신 리뷰가 먼저 오도록 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // 리뷰 삭제
  Future<void> deleteReview(String reviewId) async {
    await _reviewsCollection.doc(reviewId).delete();
  }

// TODO: 리뷰 수정, 특정 사용자의 리뷰 조회 등 추가 메서드
}