import 'package:flutter/material.dart';
import '../../../../core/constants/app_contstants.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
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

              const SizedBox(height: kSpacingMedium), // 이미지와 제목 사이 간격

              // 레시피 제목
              Text(
                recipe.title, // 레시피 객체에서 제목 가져옴
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 2, // 제목이 길면 한 줄로 제한
                overflow: TextOverflow.ellipsis, // 넘치면 ... 으로 표시
              ),

              const SizedBox(height: kSpacingSmall),

              // 레시피 요약 (재료 개수, 조리 단계 개수 등)
              Row(
                children: [
                  Icon(Icons.kitchen, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: kSpacingExtraSmall),
                  Text('${recipe.ingredients?.length ?? 0}가지 재료', style: textTheme.bodySmall),
                  const SizedBox(width: kSpacingMedium),
                  Icon(Icons.format_list_numbered, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: kSpacingExtraSmall),
                  Text('${recipe.steps?.length ?? 0}단계', style: textTheme.bodySmall),
                ],
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
    );
  }
}
