// lib/features/recipe/domain/usecases/search_recipes_usecase.dart
// Domain Layer UseCase: 레시피 검색 비즈니스 로직

import '../entities/recipe.dart'; // RecipeEntity 임포트
import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class SearchRecipesUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  SearchRecipesUseCase(this.repository);

  // UseCase 실행 메서드: 검색어를 입력으로 받아서 검색 결과 목록 반환
  // Future<List<RecipeEntity>>: 비동기로 검색 결과 목록 반환
  Future<List<RecipeEntity>> call(String query) async { // call() 메서드 사용
    // 비즈니스 로직 수행 (예: 검색어 유효성 검사, 검색어 가공)

    // Repository에게 검색 요청 위임
    return await repository.searchRecipes(query); // Repository의 searchRecipes() 메서드 호출
  }
}
