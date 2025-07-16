// lib/features/recipe/presentation/widgets/rating_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // pubspec.yaml에 flutter_rating_bar 추가!

class RatingBarWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingUpdate; // 평점 변경 시 콜백
  final double itemSize;
  final Color color;

  const RatingBarWidget({
    Key? key,
    required this.rating,
    this.onRatingUpdate,
    this.itemSize = 20,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true, // 반 별점 허용
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: color,
      ),
      onRatingUpdate: onRatingUpdate ?? (rating) {}, // 콜백이 없으면 빈 함수
      ignoreGestures: onRatingUpdate == null, // onRatingUpdate가 없으면 제스처 무시 (읽기 전용)
      itemSize: itemSize,
    );
  }
}