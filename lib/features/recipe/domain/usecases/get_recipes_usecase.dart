// lib/features/recipe/domain/usecases/get_recipes_usecase.dart
// Domain Layer UseCase: 레시피 목록 전체 조회 비즈니스 로직

import '../entities/recipe.dart'; // RecipeEntity 임포트
import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class GetRecipesUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  GetRecipesUseCase(this.repository);

  // UseCase 실행 메서드: 레시피 목록 스트림 또는 Future<List> 반환
  // RecipeRepository 인터페이스 정의에 따라 Stream<List<RecipeEntity>>를 반환
  Stream<List<RecipeEntity>> call() { // call() 메서드 사용
    // 비즈니스 로직 수행 (예: 특정 조건에 맞는 레시피만 필터링 등 - 현재는 Repository 위임)

    // Repository에게 레시피 목록 조회 요청 위임 (실시간 스트림)
    return repository.getRecipes(); // Repository의 getRecipes() 메서드 호출 (Stream 반환)
  }

// 만약 Repository.getRecipes()가 Future<List<RecipeEntity>>를 반환한다면 UseCase도 이렇게 정의:
/*
  Future<List<RecipeEntity>> call() async {
     return await repository.getRecipes();
  }
  */
}
