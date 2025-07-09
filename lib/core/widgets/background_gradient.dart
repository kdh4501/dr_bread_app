// lib/core/widgets/background_gradient.dart
import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child; // 그라데이션 위에 표시될 자식 위젯

  const BackgroundGradient({
    Key? key,
    required this.child, // 자식 위젯을 필수 매개변수로 받음
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.background, // 시작 색상 (테마에서 가져옴)
            colorScheme.primaryContainer.withOpacity(0.8), // 끝 색상 (테마에서 가져옴)
          ],
        ),
      ),
      child: child, // 자식 위젯을 그라데이션 위에 배치
    );
  }
}