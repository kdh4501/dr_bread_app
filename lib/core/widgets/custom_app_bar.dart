// lib/core/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title; // AppBar의 제목 (Text 또는 TextField 등)
  final List<Widget>? actions; // AppBar의 액션 버튼들
  final Widget? leading; // AppBar의 좌측 위젯 (뒤로가기 버튼 등)
  final bool centerTitle; // 제목 중앙 정렬 여부
  final double elevation; // 그림자 깊이

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true, // 기본값은 중앙 정렬
    this.elevation = 2.0, // 기본 그림자 깊이 (테마와 일치)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: Colors.transparent, // flexibleSpace 아래 배경을 투명하게
      foregroundColor: Colors.white, // 제목/아이콘 색상 (테마와 일치)
      iconTheme: theme.appBarTheme.iconTheme, // 테마 아이콘 색상/크기
      actionsIconTheme: theme.appBarTheme.actionsIconTheme, // 테마 액션 아이콘 색상/크기
      titleTextStyle: theme.appBarTheme.titleTextStyle, // 테마 제목 스타일

      // ↓↓↓↓↓ flexibleSpace를 사용하여 그라데이션 배경 추가 ↓↓↓↓↓
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary, // 시작 색상 (테마에서 가져옴)
              colorScheme.secondary, // 끝 색상 (테마에서 가져옴)
            ],
          ),
        ),
      ),
      // ↑↑↑↑↑ flexibleSpace를 사용하여 그라데이션 배경 추가 ↑↑↑↑↑
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // AppBar의 표준 높이
}