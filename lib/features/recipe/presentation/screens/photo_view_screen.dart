// lib/features/recipe/presentation/screens/photo_view_screen.dart
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart'; // <-- 임포트!
import 'package:cached_network_image/cached_network_image.dart'; // <-- 임포트!

class PhotoViewScreen extends StatelessWidget {
  final String imageUrl;

  const PhotoViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black, // 이미지 뷰어는 보통 검은색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 투명 앱바
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // 흰색 아이콘 (검은 배경 위)
      ),
      body: Center(
        child: Hero( // Hero 애니메이션 태그는 RecipeDetailScreen과 동일하게
          tag: 'recipeImage_${imageUrl}', // recipe.uid 대신 imageUrl로 임시 태그 (고유해야 함)
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl), // 캐시된 네트워크 이미지 사용
            backgroundDecoration: const BoxDecoration(color: Colors.black), // PhotoView 배경색
            loadingBuilder: (context, event) => Center( // 로딩 인디케이터
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  color: colorScheme.primary,
                ),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => Center( // 에러 이미지
              child: Icon(
                Icons.broken_image,
                size: 50.0,
                color: colorScheme.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}