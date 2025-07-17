// lib/core/routes/fab_transition_route.dart
import 'package:flutter/material.dart';

// HeroRectTween을 사용하여 FAB 모핑 애니메이션을 위한 커스텀 페이지 라우트
class FabTransitionRoute extends MaterialPageRoute {
  final Offset fabOrigin; // FAB의 화면상 시작 위치 (예: 중앙 하단)
  final Size fabSize; // FAB의 크기

  FabTransitionRoute({
    required WidgetBuilder builder,
    required this.fabOrigin,
    required this.fabSize,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // HeroController.createRectTween 대신 직접 Tween을 정의합니다.
    // 이는 Hero가 아닌 PageRouteBuilder의 transitionsBuilder에서 유사한 효과를 줍니다.

    // 화면 중앙을 기준으로 FAB 크기에서 전체 화면 크기로 확장하는 애니메이션
    // FAB의 실제 위치를 고려하여 계산합니다.
    final fabRectTween = RelativeRectTween(
      begin: RelativeRect.fromRect(
        fabOrigin & fabSize, // FAB의 시작 위치와 크기
        Offset.zero & MediaQuery.of(context).size, // 대상 Rect (전체 화면)
      ),
      end: RelativeRect.fromRect(
        Offset.zero & MediaQuery.of(context).size, // 대상 Rect (전체 화면)
        Offset.zero & MediaQuery.of(context).size, // 대상 Rect (전체 화면)
      ),
    );

    return ClipPath(
      // 애니메이션 진행에 따라 원형 또는 사각형 영역을 확장
      clipper: CircularRevealClipper(
        progress: animation.value,
        center: fabOrigin + Offset(fabSize.width / 2, fabSize.height / 2), // FAB의 중심 좌표
        maxRadius: MediaQuery.of(context).size.longestSide * 1.5, // 화면을 충분히 덮을 수 있는 큰 반지름
      ),
      child: FadeTransition( // 클립 애니메이션과 함께 페이드 인 효과 추가
        opacity: animation,
        child: child,
      ),
    );
  }
}

// 원형 확장을 위한 커스텀 클리퍼
class CircularRevealClipper extends CustomClipper<Path> {
  final double progress; // 애니메이션 진행도 (0.0 ~ 1.0)
  final Offset center;   // 클립핑 시작 지점 (FAB의 중심)
  final double maxRadius; // 클립핑할 원의 최대 반지름 (화면을 충분히 덮을 크기)

  CircularRevealClipper({required this.progress, required this.center, required this.maxRadius});

  @override
  Path getClip(Size size) {
    final radius = maxRadius * progress; // 진행도에 따라 반지름 확장

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) => oldClipper.progress != progress;
}