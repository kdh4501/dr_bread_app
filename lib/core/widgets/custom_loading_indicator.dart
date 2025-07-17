// lib/core/widgets/custom_loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Lottie 임포트


class CustomLoadingIndicator extends StatelessWidget {
  // Lottie 애니메이션 파일 경로
  final String lottieAssetPath;
  // 애니메이션 크기 (기본값)
  final double size;
  // 배경색 (선택 사항)
  final Color? backgroundColor;

  const CustomLoadingIndicator({
    Key? key,
    this.lottieAssetPath = 'assets/lottie/baking_bread_loader.json', // 기본 Lottie 파일
    this.size = 150, // 기본 크기
    this.backgroundColor, // 배경색 (Scaffold 등을 투명하게 하여 그라데이션 위에 띄울 때 유용)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 만약 배경색이 지정되었다면 해당 색상으로 컨테이너를 채웁니다.
    // 그렇지 않으면 단순히 Lottie 애니메이션만 반환합니다.
    // 일반적으로 로딩 인디케이터는 배경 위에 바로 띄워지므로 backgroundColor를 사용하는 경우는 드뭅니다.
    final Widget lottieAnimation = Lottie.asset(
      lottieAssetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: true, // 반복 재생
    );

    if (backgroundColor != null) {
      return Container(
        color: backgroundColor,
        child: Center(child: lottieAnimation),
      );
    } else {
      return Center(child: lottieAnimation);
    }
  }
}
