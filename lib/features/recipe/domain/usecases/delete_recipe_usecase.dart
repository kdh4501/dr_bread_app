// lib/features/recipe/domain/usecases/delete_recipe_usecase.dart
// Domain Layer UseCase: 특정 레시피 삭제 비즈니스 로직

import 'package:dr_bread_app/features/recipe/domain/repositories/storage_repository.dart';
import 'package:flutter/cupertino.dart';

import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class DeleteRecipeUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository recipeRepository;
  final StorageRepository storageRepository;

  // 생성자로 Repository 구현체를 주입받음
  DeleteRecipeUseCase(this.recipeRepository, this.storageRepository);

  // UseCase 실행 메서드: 삭제할 레시피의 UID를 입력으로 받음
  // Future<void>: 비동기로 작업 완료 시 반환 (결과값 없음)
  Future<void> call(String uid, {String? imageUrl}) async { // call() 메서드 사용
    debugPrint('DeleteRecipeUseCase: Deleteing image from Storage...');
    // 비즈니스 로직 수행 (필요하다면 여기서 삭제 전 검증 등을 넣을 수 있음)
    // step 1: Storage에서 사진 파일 먼저 삭제
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        debugPrint('DeleteRecipeUseCase: Deleting image from Storage...'); // 이미지 삭제 시작 로그
        await storageRepository.deleteImage(imageUrl); // <-- StorageRepository 호출!
        debugPrint('DeleteRecipeUseCase: Image deleted successfully.'); // 이미지 삭제 성공 로그
      } catch (e) {
        // 이미지 삭제 실패 시 (예: 파일이 없거나 권한 문제)
        // TODO: 이미지 삭제 실패 시 레시피 데이터 삭제를 중단할지, 계속 진행할지 정책 결정
        // 현재는 이미지 삭제 실패해도 레시피 데이터 삭제는 진행하도록 함 (경고만 출력)
        debugPrint('DeleteRecipeUseCase: Failed to delete image from Storage: $e');
        // throw Exception('이미지 삭제 실패: $e'); // 만약 이미지 삭제 실패 시 레시피 삭제 전체를 중단하려면
      }
    }

    // step 2: Firestore에서 레시피 데이터 삭제
    debugPrint('DeleteRecipeUseCase: Deleting recipe data from Firestore...'); // 레시피 데이터 삭제 시작 로그
    await recipeRepository.deleteRecipe(uid); // <-- RecipeRepository 호출!
    debugPrint('DeleteRecipeUseCase: Recipe data deleted successfully.'); // 레시피 데이터 삭제 성공 로그
  }
}
