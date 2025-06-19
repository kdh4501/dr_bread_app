// lib/core/constants/app_constants.dart
// 빵빵박사 앱 전체에서 사용되는 상수 정의

import 'package:flutter/material.dart'; // 필요시 Material 관련 상수 사용

// --- 간격 및 패딩 상수 ---
const double kDefaultPadding = 16.0; // 기본 전체 패딩
const double kDefaultHorizontalPadding = 16.0; // 기본 수평 패딩
const double kDefaultVerticalPadding = 16.0; // 기본 수직 패딩

const double kSpacingExtraSmall = 4.0;
const double kSpacingSmall = 8.0; // 작은 간격
const double kSpacingMedium = 16.0; // 기본 간격
const double kSpacingLarge = 24.0; // 큰 간격
const double kSpacingExtraLarge = 32.0; // 아주 큰 간격


// --- 데이터 관련 상수 ---
const String kRecipesCollection = 'recipes'; // Firestore 레시피 컬렉션 이름
const String kRecipeImagesStoragePath = 'recipe_images'; // Firebase Storage 레시피 이미지 기본 경로


// --- 앱 정보 상수 ---
const String kAppName = '빵빵박사'; // 앱 이름