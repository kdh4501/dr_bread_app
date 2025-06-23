// lib/features/recipe/domain/usecases/add_recipe_usecase.dart
// Domain Layer UseCase: 새로운 레시피 추가 비즈니스 로직

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../../../main.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../entities/recipe.dart'; // RecipeEntity 임포트
import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class AddRecipeUseCase {
  // Repository 인터페이스에 의존 (구현체는 몰라!)
  final RecipeRepository repository;
  final AuthRepository authRepository;

  // 생성자로 Repository 구현체를 주입받음
  AddRecipeUseCase(this.repository, this.authRepository);

  // UseCase 실행 메서드: AddRecipeScreen에서 입력받은 RecipeEntity 객체를 받음
  // Future<void> 또는 Future<String> (새로 생성된 레시피 ID 반환 시) 등으로 반환 타입 지정
  Future<String> call(RecipeEntity recipe) async { // call() 메서드 사용 (관례)
    // 비즈니스 로직 수행 (필요하다면 여기서 추가 검증이나 가공 로직을 넣을 수 있음)
    // 예: recipe 데이터 유효성 추가 검사

    // ↓↓↓↓↓ 비즈니스 로직 수행: 작성자 UID 및 생성 날짜 설정 ↓↓↓↓↓
    // 현재 로그인된 사용자 UID 가져오기 (AuthRepository 사용)
    final currentUser = await authRepository.getCurrentUser(); // TODO: AuthRepository에 getCurrentUser 메서드 추가 필요
    // TODO: 또는 authRepository.authStateChanges.first 로 현재 사용자 정보 가져오기
    // 또는 getIt<FirebaseAuth>().currentUser?.uid 로 직접 가져오기 (Domain Layer에서 Firebase 직접 의존은 지양)
    final String? authorUid = getIt<FirebaseAuth>().currentUser?.uid;
    final recipeWithMetadata = recipe.copyWith(
      authorUid: authorUid,
      createdAt: DateTime.now(), // 현재 시간 설정 (DataSource에서 서버 타임스탬프로 덮어쓸 수 있음)
      updatedAt: DateTime.now(), // 현재 시간 설정 (DataSource에서 서버 타임스탬프로 덮어쓸 수 있음)
    );

    // TODO: 비즈니스 규칙에 따른 추가 유효성 검사 (예: 제목 길이, 재료/단계 최소 개수 등)
    if (recipeWithMetadata.title.isEmpty) {
      throw Exception('레시피 제목은 비어있을 수 없습니다.'); // 비즈니스 규칙 위반 시 에러 발생
    }
    // if (recipeWithMetadata.ingredients == null || recipeWithMetadata.ingredients!.isEmpty) {
    //    throw Exception('재료를 최소 하나 이상 입력해야 합니다.');
    // }

    // Repository는 Data Layer에 구현되어 Firestore에 저장하는 역할을 함
    // Repository에게 메타데이터가 추가된 RecipeEntity 객체 전달
    final newRecipeId = await repository.addRecipe(recipeWithMetadata); // <-- Repository의 addRecipe 메서드 호출
    debugPrint('AddRecipeUseCase: repository.addRecipe finished. New ID: $newRecipeId'); // Repository 호출 완료 로그
    // Repository에게 데이터 추가 요청 위임
    // Repository는 Data Layer에 구현되어 Firestore에 저장하는 역할을 함
    return newRecipeId; // Repository의 addRecipe 메서드 호출
  }
}
