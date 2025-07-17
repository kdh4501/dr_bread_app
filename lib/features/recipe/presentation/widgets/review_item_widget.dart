// lib/features/recipe/presentation/widgets/review_item_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅용, pubspec.yaml에 intl 추가!
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/review.dart';
import 'rating_bar_widget.dart';

class ReviewItemWidget extends StatelessWidget {
  final ReviewEntity review;
  final bool isMyReview; // 내 리뷰인지 여부
  final VoidCallback? onDelete; // 삭제 콜백
  final VoidCallback? onEdit; // 수정 콜백

  const ReviewItemWidget({
    Key? key,
    required this.review,
    this.isMyReview = false,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 작성자 프로필 사진
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.surfaceVariant,
                  backgroundImage: review.authorPhotoUrl != null
                      ? CachedNetworkImageProvider(review.authorPhotoUrl!) as ImageProvider
                      : null,
                  child: review.authorPhotoUrl == null
                      ? Icon(Icons.person, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: kSpacingSmall),
                // 작성자 닉네임
                Text(
                  review.authorDisplayName ?? '익명',
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(width: kSpacingSmall),
                // 평점
                RatingBarWidget(
                  rating: review.rating,
                  itemSize: 16,
                  color: colorScheme.primary,
                ),
                const Spacer(), // 남은 공간 채우기
                // 작성 시간
                Text(
                  DateFormat('yy.MM.dd').format(review.createdAt),
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                // 내 리뷰인 경우 삭제 버튼
                if (isMyReview && onDelete != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 수정 버튼
                      IconButton(
                        icon: Icon(Icons.edit_note, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                        onPressed: onEdit, // <-- 여기에 연결!
                      ),
                      // 삭제 버튼
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: kSpacingSmall),
            // 리뷰 내용
            Text(
              review.reviewText,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            // TODO: 더보기 버튼 (리뷰 내용이 길 경우)
          ],
        ),
      ),
    );
  }
}