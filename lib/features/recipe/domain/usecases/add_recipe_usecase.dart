// lib/features/recipe/domain/usecases/add_recipe_usecase.dart
// Domain Layer UseCase: 새로운 레시피 추가 비즈니스 로직

import '../entities/recipe.dart'; // RecipeEntity 임포트
import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class AddRecipeUseCase {
  // Repository 인터페이스에 의존 (구현체는 몰라!)
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  AddRecipeUseCase(this.repository);

  // UseCase 실행 메서드: AddRecipeScreen에서 입력받은 RecipeEntity 객체를 받음
  // Future<void> 또는 Future<String> (새로 생성된 레시피 ID 반환 시) 등으로 반환 타입 지정
  Future<String> call(RecipeEntity recipe) async { // call() 메서드 사용 (관례)
    // 비즈니스 로직 수행 (필요하다면 여기서 추가 검증이나 가공 로직을 넣을 수 있음)
    // 예: recipe 데이터 유효성 추가 검사

    // Repository에게 데이터 추가 요청 위임
    // Repository는 Data Layer에 구현되어 Firestore에 저장하는 역할을 함
    return await repository.addRecipe(recipe); // Repository의 addRecipe 메서드 호출
  }
}
