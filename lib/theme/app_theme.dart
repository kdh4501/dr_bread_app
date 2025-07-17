// lib/theme/app_theme.dart
// 빵빵박사 앱의 Material Design 테마 정의

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

// 빵빵박사 앱의 Material Design 가이드라인을 담은 ThemeData 상수 정의
// const 키워드를 사용하여 컴파일 시점에 값이 결정되도록 함 (성능 최적화)
ThemeData bbangbaksaTheme = ThemeData(
  // Material 3 디자인 사용
  useMaterial3: true,

  // --- 색상 팔레트 설정 (네 가이드라인 기반) ---
  // Color 객체는 0xFF + Hex 코드 형태로 정의
  colorScheme: ColorScheme.light( // 밝은 테마
    // 메인 색상: LightSalmon (FFA07A) 또는 Gold (FFD700) - 여기서는 LightSalmon 선택
    primary: AppColors.lightSalmon, // 메인 색상 (LightSalmon)
    onPrimary: AppColors.white, // 메인 색상 위 텍스트/아이콘 색상 (대비)
    primaryContainer: AppColors.lightSalmonContainer, // 메인 색상의 더 밝은 버전 (Material 3)
    onPrimaryContainer: AppColors.charcoal, // primaryContainer 위 텍스트/아이콘 색

    // 보조 색상: PaleGreen (98FB98) 또는 LightPink (FFB6C1) - 여기서는 PaleGreen 선택
    secondary: AppColors.paleGreen, // 보조 색상 (PaleGreen)
    onSecondary: AppColors.charcoal, // 보조 색상 위 텍스트/아이콘 색상 (대비)
    secondaryContainer: AppColors.paleGreenContainer, // 보조 색상의 더 밝은 버전
    onSecondaryContainer: AppColors.charcoal,

    // 배경색: LemonChiffon (FFFACD) 또는 White (FFFFFF) - 여기서는 LemonChiffon 선택
    background: AppColors.lemonChiffon, // 배경색 (LemonChiffon)
    onBackground: AppColors.charcoal, // 배경색 위 텍스트 색상 (Charcoal)

    // 표면 색상: 카드, 시트 등 (White 선택)
    surface: AppColors.white, // 표면 색상
    onSurface: AppColors.charcoal, // 표면 색상 위 텍스트 색상
    surfaceVariant: AppColors.lightGrey, // 표면의 변형색 (컨테이너 배경 등)
    onSurfaceVariant: AppColors.darkGrey, // surfaceVariant 위 텍스트/아이콘 색상

    // 에러 색상
    error: AppColors.redAccent, // 에러 색상
    onError: AppColors.white, // 에러 색상 위 텍스트 색상

    // 테두리/구분선 색상 (Material 3)
    outline: AppColors.grey400, // 테두리 색상 (부드러운 느낌)
    outlineVariant: AppColors.grey300, // 테두리 변형색
  ),

  // --- 타이포그래피 (폰트) 설정 ---
  // Google Fonts 패키지 사용 예시
  fontFamily: GoogleFonts.nanumGothic().fontFamily, // 나눔고딕 폰트 적용 (pubspec.yaml에 google_fonts 추가 필요)

  textTheme: TextTheme(
    // Headline (가장 큰 제목)
    headlineLarge: GoogleFonts.nanumGothic(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.charcoal),
    headlineMedium: GoogleFonts.nanumGothic(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.charcoal),
    headlineSmall: GoogleFonts.nanumGothic(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),

    // Title (섹션 제목, 앱바 제목)
    titleLarge: GoogleFonts.nanumGothic(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white), // 앱바 제목 등
    titleMedium: GoogleFonts.nanumGothic(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal), // 섹션 제목, 카드 제목
    titleSmall: GoogleFonts.nanumGothic(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.charcoal),

    // Body (본문 텍스트)
    bodyLarge: GoogleFonts.nanumGothic(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.charcoal),
    bodyMedium: GoogleFonts.nanumGothic(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.charcoal),
    bodySmall: GoogleFonts.nanumGothic(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.darkGrey), // 작은 보조 텍스트

    // Label (버튼 텍스트, 입력 필드 라벨)
    labelLarge: GoogleFonts.nanumGothic(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white), // 버튼 텍스트
    labelMedium: GoogleFonts.nanumGothic(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.charcoal),
    labelSmall: GoogleFonts.nanumGothic(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
  ),

  // --- 형태 (Shape) 설정 (빵처럼 부드러운 모서리) ---
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // 카드 모서리 (더 부드럽게)
    elevation: 4.0, // 그림자 깊이
    margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), // 마진은 각 위젯에서 kSpacingMedium 등으로 조절
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // 버튼 모서리 (더 부드럽게)
      backgroundColor: AppColors.lightSalmon, // 메인 색상
      foregroundColor: AppColors.white, // 텍스트/아이콘 색상
      textStyle: GoogleFonts.nanumGothic(fontSize: 16, fontWeight: FontWeight.w600), // 버튼 텍스트 스타일
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 버튼 패딩
      elevation: 3.0, // 그림자
    ),
  ),
  textButtonTheme: TextButtonThemeData( // TextButton 테마 추가
    style: TextButton.styleFrom(
      foregroundColor: AppColors.lightSalmon, // 메인 색상
      textStyle: GoogleFonts.nanumGothic(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // 모서리 둥글게
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.paleGreen, // 보조 색상
    foregroundColor: AppColors.charcoal, // 메인 색상
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)), // FAB는 더 둥글게 (거의 원형)
    elevation: 6.0,
  ),
  appBarTheme: AppBarTheme(
    // backgroundColor: const Color(0xFFFFA07A), // 메인 색상
    foregroundColor: AppColors.white, // 제목/아이콘 색상
    elevation: 2.0, // 그림자 깊이 (살짝만)
    centerTitle: true, // 제목 중앙 정렬
    titleTextStyle: GoogleFonts.nanumGothic(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white), // 앱바 제목 스타일
    iconTheme: const IconThemeData(color: AppColors.white, size: 24), // 앱바 아이콘 색상/크기
    actionsIconTheme: const IconThemeData(color: AppColors.white, size: 24), // 액션 아이콘 색상/크기
  ),
  inputDecorationTheme: InputDecorationTheme( // 입력 필드 테마
    filled: true, // 배경색 채우기 활성화
    fillColor: AppColors.lightSalmonContainer,
    hoverColor: AppColors.grey300, // 호버 시 색상
    focusColor: AppColors.lightSalmon, // 포커스 시 색상
    border: OutlineInputBorder( // 기본 테두리 스타일
      borderRadius: BorderRadius.circular(12.0), // 모서리 둥글기 (더 부드럽게)
      borderSide: BorderSide(color: AppColors.grey300, width: 1.0), // 기본 테두리 색상
    ),
    enabledBorder: OutlineInputBorder( // 활성화 시 테두리
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder( // 포커스 시 테두리
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.lightSalmon, width: 2.0), // 메인 색상으로 강조
    ),
    errorBorder: OutlineInputBorder( // 에러 시 테두리
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.redAccent, width: 2.0), // 에러 색상으로 강조
    ),
    focusedErrorBorder: OutlineInputBorder( // 포커스된 에러 시 테두리
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.redAccent, width: 2.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // 내부 패딩
    hintStyle: GoogleFonts.nanumGothic(fontSize: 14, color: AppColors.grey500), // 힌트 텍스트 스타일
    labelStyle: GoogleFonts.nanumGothic(fontSize: 14, color: AppColors.grey700), // 라벨 텍스트 스타일
    errorStyle: GoogleFonts.nanumGothic(fontSize: 12, color: AppColors.redAccent), // 에러 텍스트 스타일
  ),

  // SliderThemeData 추가
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.lightSalmon, // 활성 트랙 색상 (primary)
    inactiveTrackColor: AppColors.lightSalmon.withOpacity(0.3), // 비활성 트랙 색상
    thumbColor: AppColors.lightSalmon, // 엄지(thumb) 색상
    overlayColor: AppColors.lightSalmon.withOpacity(0.2), // 오버레이 색상
    valueIndicatorColor: AppColors.charcoal, // 값 표시기 배경색 (Charcoal)
    valueIndicatorTextStyle: GoogleFonts.nanumGothic(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold), // 값 표시기 텍스트 스타일
  ),

  // ChipThemeData 추가
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.paleGreenContainer, // secondaryContainer (PaleGreen의 밝은 버전)
    labelStyle: GoogleFonts.nanumGothic(fontSize: 12, color: AppColors.charcoal), // onSecondaryContainer
    deleteIconColor: AppColors.charcoal, // onSecondaryContainer
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // 모서리 둥글게
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 내부 패딩
    selectedColor: AppColors.paleGreen, // 선택됐을 때 색상 (secondary)
    secondaryLabelStyle: GoogleFonts.nanumGothic(fontSize: 12, color: AppColors.charcoal), // 선택됐을 때 라벨 스타일
    secondarySelectedColor: AppColors.paleGreen, // 선택됐을 때 보조 색상
  ),

  iconTheme: const IconThemeData(color: Color(0xFF36454F), size: 24), // 기본 아이콘 색상/크기
  // TODO: DialogTheme, BottomSheetTheme, SnackBarTheme 등 추가
  dialogTheme: DialogTheme( // 다이얼로그 테마
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // 모서리 둥글게
    backgroundColor: AppColors.white,
    titleTextStyle: GoogleFonts.nanumGothic(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal),
    contentTextStyle: GoogleFonts.nanumGothic(fontSize: 16, color: AppColors.charcoal),
  ),
  bottomSheetTheme: BottomSheetThemeData( // BottomSheet 테마
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder( // 상단 모서리만 둥글게
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    elevation: 8.0,
  ),
  snackBarTheme: SnackBarThemeData( // SnackBar 테마
    backgroundColor: AppColors.charcoal, // 어두운 배경 (텍스트 대비)
    contentTextStyle: GoogleFonts.nanumGothic(fontSize: 14, color: AppColors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // 모서리 둥글게
    behavior: SnackBarBehavior.floating, // 플로팅 스낵바
    elevation: 6.0,
  ),
);

// TODO: 필요시 다크 모드 테마 등 다른 테마 정의
// const