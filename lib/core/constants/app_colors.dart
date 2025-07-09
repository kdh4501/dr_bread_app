// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

// 빵빵박사 앱의 핵심 색상 팔레트 상수 정의
class AppColors {
  // Primary Colors
  static const Color lightSalmon = Color(0xFFFFA07A); // 메인 (Primary)
  static const Color lightSalmonContainer = Color(0xFFFEDBD0); // 메인 컨테이너 (PrimaryContainer)

  // Secondary Colors
  static const Color paleGreen = Color(0xFF98FB98); // 보조 (Secondary)
  static const Color paleGreenContainer = Color(0xFFE0F7FA); // 보조 컨테이너 (SecondaryContainer)

  // Background & Surface Colors
  static const Color lemonChiffon = Color(0xFFFFFACD); // 배경 (Background)
  static const Color charcoal = Color(0xFF36454F); // 배경 위 텍스트 (onBackground), 표면 위 텍스트 (onSurface)
  static const Color white = Colors.white; // 표면 (Surface), 메인 위 텍스트 (onPrimary), 에러 위 텍스트 (onError)
  static const Color lightGrey = Color(0xFFE0E0E0); // 표면 변형 (SurfaceVariant)
  static const Color darkGrey = Color(0xFF424242); // 표면 변형 위 텍스트 (onSurfaceVariant)

  // Error Color
  static const Color redAccent = Colors.redAccent; // 에러 (Error)

  // Outline/Border Colors
  static const Color grey400 = Color(0xFFBDBDBD); // outline (Colors.grey.shade400)
  static const Color grey300 = Color(0xFFE0E0E0); // outlineVariant (Colors.grey.shade300)
  static const Color grey500 = Color(0xFF9E9E9E); // 힌트 텍스트 (Colors.grey.shade500)
  static const Color grey700 = Color(0xFF616161); // 라벨 텍스트 (Colors.grey.shade700)
}