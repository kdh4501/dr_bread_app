// lib/theme/app_theme.dart
// 빵빵박사 앱의 Material Design 테마 정의

import 'package:flutter/material.dart';

// 빵빵박사 앱의 Material Design 가이드라인을 담은 ThemeData 상수 정의
// const 키워드를 사용하여 컴파일 시점에 값이 결정되도록 함 (성능 최적화)
ThemeData bbangbaksaTheme = ThemeData(
  // Material 3 디자인 사용
  useMaterial3: true,

  // --- 색상 팔레트 설정 (네 가이드라인 기반) ---
  // Color 객체는 0xFF + Hex 코드 형태로 정의
  colorScheme: ColorScheme.light( // 밝은 테마
    primary: Color(0xFFFFA07A), // 메인 색상 (LightSalmon 예시)
    onPrimary: Colors.white, // 메인 색상 위 텍스트/아이콘 색상
    secondary: Color(0xFF98FB98), // 보조 색상 (PaleGreen 예시)
    onSecondary: Colors.black87, // 보조 색상 위 텍스트/아이콘 색상
    background: Color(0xFFFFFACD), // 배경색 (LemonChiffon 예시)
    onBackground: Color(0xFF36454F), // 배경색 위 텍스트 색상 (Charcoal 예시)
    surface: Colors.white, // 카드, 시트 등 표면 색상 (White 예시)
    onSurface: Color(0xFF36454F), // 표면 색상 위 텍스트 색상 (Charcoal 예시)
    error: Colors.redAccent, // 에러 색상
    onError: Colors.white, // 에러 색상 위 텍스트 색상
    // TODO: Gold, LightPink, Black 등 다른 색상 조합도 고려하여 colorScheme 정의
    // 예: Gold/LightPink 조합 colorScheme
    // primary: Color(0xFFFFD700), // Gold
    // secondary: Color(0xFFffb6c1), // LightPink
    // background: Colors.white, // White
    // onBackground: Colors.black, // Black
  ),

  // --- 형태 (Shape) 설정 (빵처럼 부드러운 모서리) ---
  cardTheme: CardTheme( // 카드 위젯 테마
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // 모서리 둥글기 (예시: 16.0)
    elevation: 4.0,
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData( // ElevatedButton 테마
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // 모서리 둥글기 (예시: 8.0)
      // TODO: 색상, 텍스트 스타일 등 colorScheme 및 textTheme에서 가져와 적용
      backgroundColor: Color(0xFFFFA07A), // 메인 색상 (LightSalmon 예시)
      foregroundColor: Colors.white, // 텍스트/아이콘 색상
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // 버튼 텍스트 스타일 (예시)
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData( // FAB 테마
    backgroundColor: Color(0xFF98FB98), // 보조 색상 (PaleGreen 예시)
    foregroundColor: Color(0xFFFFA07A), // 메인 색상 (LightSalmon 예시)
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)), // FAB는 보통 더 둥글게
  ),
  appBarTheme: const AppBarTheme( // 앱바 테마
    backgroundColor: Color(0xFFFFA07A), // 메인 색상 (LightSalmon 예시)
    foregroundColor: Colors.white, // 제목/아이콘 색상
    elevation: 4.0,
  ),
  inputDecorationTheme: InputDecorationTheme( // 입력 필드 테마
    border: OutlineInputBorder( // 기본 테두리 스타일
      borderRadius: BorderRadius.circular(8.0), // 모서리 둥글기 (예시: 8.0)
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0), // 내부 패딩
    // TODO: 색상, 텍스트 스타일 등 colorScheme 및 textTheme에서 가져와 적용
  ),
  // TODO: 다른 컴포넌트 테마 설정 (Dialog, BottomNavigationBar 등)


  // --- 타이포그래피 (폰트) 설정 ---
  // TODO: Google Fonts 패키지 추가 및 폰트 파일 임포트 후 fontFamily 설정
  // fontFamily: 'NanumGothic', // 예시 폰트 이름

  // TODO: TextTheme에 각 스타일 정의 (크기, 굵기 등)
  // textTheme: const TextTheme(
  //    titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 제목 스타일
  //    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500), // 부제목 스타일
  //    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal), // 본문 스타일
  //    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // 버튼 텍스트 스타일 (Material 3)
  //    // ...
  // ),

  // --- 레이아웃 규칙 (ThemeData에 직접 설정하기는 어렵지만, 코딩 시 활용) ---
  // TODO: 화면 좌우 기본 패딩, 요소 간 기본 간격 등은 const 변수로 정의하여 사용
  // 예: const double kDefaultPadding = 16.0;
  // 예: const double kDefaultSpacing = 16.0;

);

// TODO: 필요시 다크 모드 테마 등 다른 테마 정의
// const ThemeData bbangbaksaDarkTheme = ThemeData( ... );
