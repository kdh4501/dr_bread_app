// lib/features/recipe/domain/usecases/get_recipe_detail_usecase.dart
// Domain Layer UseCase: 특정 레시피 상세 정보 조회 비즈니스 로직

import '../entities/recipe.dart'; // RecipeEntity 임포트
import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class GetRecipeDetailUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  GetRecipeDetailUseCase(this.repository);

  // UseCase 실행 메서드: 조회할 레시피의 UID를 입력으로 받음
  // Future<RecipeEntity?>: 비동기로 RecipeEntity 객체 또는 null 반환
  Future<RecipeEntity?> call(String uid) async { // call() 메서드 사용
    // 비즈니스 로직 수행 (필요하다면 여기서 추가 검증 등을 넣을 수 있음)
    // 예: uid가 유효한 형식인지 검사

    // Repository에게 상세 정보 조회 요청 위임
    return await repository.getRecipeDetail(uid); // Repository의 getRecipeDetail 메서드 호출
  }
}
