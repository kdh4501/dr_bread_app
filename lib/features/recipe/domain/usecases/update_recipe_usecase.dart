// lib/features/recipe/domain/usecases/update_recipe_usecase.dart
// Domain Layer UseCase: 기존 레시피 업데이트 비즈니스 로직

import '../../../recipe/domain/entities/recipe.dart'; // RecipeEntity 임포트
import '../../../recipe/domain/repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class UpdateRecipeUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  UpdateRecipeUseCase(this.repository);

  // UseCase 실행 메서드: AddRecipeScreen에서 수정된 RecipeEntity 객체를 받음 (UID 포함)
  Future<void> call(RecipeEntity recipe) async { // call() 메서드 사용
    // 비즈니스 로직 수행 (필요하다면 여기서 업데이트 전 검증 등을 넣을 수 있음)
    // 예: recipe.uid가 유효한지 검사

    // Repository에게 데이터 업데이트 요청 위임
    await repository.updateRecipe(recipe); // Repository의 updateRecipe 메서드 호출
  }
}
