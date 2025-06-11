import 'package:flutter/material.dart';
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
  const RecipeCard({Key? key, required this.recipe, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // InkWell을 사용하여 위젯을 탭 가능하게 만들고, 탭 효과 추가
    return InkWell(
      onTap: onTap, // 외부에서 받은 onTap 함수 연결
      // Card 위젯으로 전체적인 카드 모양과 그림자 효과 적용
      child: Card(
        // TODO: main.dart의 CardTheme에 설정된 값 사용 또는 여기서 재정의
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              // 레시피 사진 (URL 사용, 캐싱 적용)
              // Firestore에 사진 URL을 저장하고 여기서 불러옴
              if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty) // photoUrl이 있고 비어있지 않으면
                ClipRRect( // 이미지 모서리 둥글게
                  borderRadius: BorderRadius.circular(8.0),
                  // CachedNetworkImage 사용 (성능, 로딩/에러 표시 편리)
                  child: CachedNetworkImage( // pubspec.yaml에 cached_network_image 패키지 추가 필요
                    imageUrl: recipe.photoUrl!, // photoUrl은 String? -> !. 로 널 아님을 단언 (if문에서 체크했으므로 안전)
                    width: double.infinity, // 가로 전체 사용
                    height: 180, // 이미지 높이 고정
                    fit: BoxFit.cover, // 비율 유지하며 영역 채우기
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // 로딩 중 표시
                    errorWidget: (context, url, error) => const Icon(Icons.error_outline), // 에러 시 표시
                  ),
                )
              else
              // 사진 없을 때 기본 이미지 또는 Placeholder 표시
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
                ),

              const SizedBox(height: 12), // 이미지와 제목 사이 간격

              // 레시피 제목
              Text(
                recipe.title, // 레시피 객체에서 제목 가져옴
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1, // 제목이 길면 한 줄로 제한
                overflow: TextOverflow.ellipsis, // 넘치면 ... 으로 표시
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
