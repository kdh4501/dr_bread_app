// lib/features/recipe/domain/usecases/delete_recipe_usecase.dart
// Domain Layer UseCase: 특정 레시피 삭제 비즈니스 로직

import '../repositories/recipe_repository.dart'; // RecipeRepository 인터페이스 임포트

class DeleteRecipeUseCase {
  // Repository 인터페이스에 의존
  final RecipeRepository repository;

  // 생성자로 Repository 구현체를 주입받음
  DeleteRecipeUseCase(this.repository);

  // UseCase 실행 메서드: 삭제할 레시피의 UID를 입력으로 받음
  // Future<void>: 비동기로 작업 완료 시 반환 (결과값 없음)
  Future<void> call(String uid) async { // call() 메서드 사용
    // 비즈니스 로직 수행 (필요하다면 여기서 삭제 전 검증 등을 넣을 수 있음)
    // 예: 삭제 권한이 있는지 확인 (작성자 본인인지 등)

    // Repository에게 데이터 삭제 요청 위임
    await repository.deleteRecipe(uid); // Repository의 deleteRecipe 메서드 호출
  }
}
