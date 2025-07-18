import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
import 'package:cached_network_image/cached_network_image.dart'; // 이미지 캐싱 패키지 (선택, 권장)

/*
재사용 가능한 UI
 */
class RecipeCard extends StatelessWidget {
  // 외부에서 레시피 데이터와 탭 콜백 함수를 받음
  final RecipeEntity recipe;
  final VoidCallback onTap; // 카드가 눌렸을 때 실행될 함수

  // 생성자: 필수 매개변수로 정의
  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(  // Card 위젯으로 전체적인 카드 모양과 그림자 효과 적용
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      child: InkWell( // 터치 시 물결 효과
        onTap: onTap, // 외부에서 받은 onTap 함수 연결
        borderRadius: BorderRadius.circular(theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context)).topLeft.x : 0.0), // Card의 모서리 둥글기와 일치
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.cardTheme.shape is RoundedRectangleBorder
                ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context)).topLeft.x : 0.0),
            gradient: LinearGradient( // 은은한 그라데이션
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface, // 시작 색상 (흰색)
                colorScheme.surfaceVariant.withOpacity(0.5), // 끝 색상 (더 밝은 회색, 투명도 조절)
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                Stack(
                  children: [
                    // 레시피 사진 (URL 사용, 캐싱 적용)
                    // Firestore에 사진 URL을 저장하고 여기서 불러옴
                    if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty) // photoUrl이 있고 비어있지 않으면
                      Hero( // Hero 애니메이션 (상세 화면 전환 시 부드러운 이미지 이동)
                        tag: 'recipeImage_${recipe.uid}', // 고유한 태그
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(kSpacingSmall), // 이미지 모서리 둥글기
                          child: CachedNetworkImage(
                            imageUrl: recipe.photoUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180,
                              color: colorScheme.surfaceVariant,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 180,
                              color: colorScheme.surfaceVariant,
                              child: Icon(Icons.broken_image, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      )
                    else
                    // 사진 없을 때 기본 이미지 또는 Placeholder 표시
                      Container(
                        width: double.infinity,
                        height: 180,
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.image_not_supported, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                      ),

                    // ↓↓↓↓↓ 카테고리 뱃지 오버레이 ↓↓↓↓↓
                    if (recipe.category != null && recipe.category!.isNotEmpty)
                      Positioned( // 이미지 위에 배치
                        top: kSpacingSmall, // 상단 여백
                        left: kSpacingSmall, // 좌측 여백
                        child: Chip(
                          label: Text(
                            recipe.category!,
                            style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary), // labelMedium, onPrimary
                          ),
                          backgroundColor: colorScheme.primary, // primary 색상
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kSpacingSmall)), // 모서리 둥글게
                          padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingExtraSmall), // 내부 패딩
                          elevation: 2.0, // 그림자 추가
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: kSpacingMedium), // 이미지와 제목 사이 간격

                // 레시피 제목 및 즐겨찾기 아이콘
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title, // 레시피 객체에서 제목 가져옴
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2, // 제목이 길면 한 줄로 제한
                        overflow: TextOverflow.ellipsis, // 넘치면 ... 으로 표시
                      ),
                    ),
                    // 즐겨찾기 아이콘 추가
                    if (recipe.isFavorite == true) // isFavorite가 true일 때만 표시
                      Padding(
                        padding: const EdgeInsets.only(left: kSpacingSmall), // 좌측 여백
                        child: Icon(
                          Icons.favorite, // 채워진 하트
                          size: kIconSizeMedium,
                          color: AppColors.redAccent, // 강조를 위해 직접 RedAccent 색상 사용 (테마에 없으면 colorScheme.error 등)
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: kSpacingSmall),

                // 레시피 요약 (재료 개수, 조리 단계 개수 등)
                Row(
                  children: [
                    Icon(Icons.kitchen, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: kSpacingExtraSmall),
                    Text('${recipe.ingredients?.length ?? 0}가지 재료', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface)),
                    const SizedBox(width: kSpacingMedium),
                    Icon(Icons.format_list_numbered, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: kSpacingExtraSmall),
                    Text('${recipe.steps?.length ?? 0}단계', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface)),
                  ],
                ),

                // 카테고리 표시
                if (recipe.category != null && recipe.category!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.category, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: kSpacingExtraSmall),
                      Text(recipe.category!, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface)),
                    ],
                  ),

                // 태그 표시
                if (recipe.tags != null && recipe.category!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: kSpacingSmall),
                    child: Wrap(  // 태그들이 자동으로 줄 바꿈되도록 Wrap 사용
                      spacing: kSpacingSmall, // 태그 간 가로 간격
                      runSpacing: kSpacingSmall,  // 태그 간 세로 간격
                      children: recipe.tags!
                          .map((tag) => Chip(
                        label: Text(tag),
                      ))
                          .toList(),
                    ),
                  ),
                // TODO: 레시피 간단 설명, 작성자, 날짜 등 추가 정보 표시 (RecipeEntity에 있다면)
                // if (recipe.description != null && recipe.description!.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 4.0),
                //     child: Text(
                //       recipe.description!,
                //       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                //       maxLines: 2,
                //       overflow: TextOverflow.ellipsis,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
