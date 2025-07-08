// lib/features/recipe/domain/repositories/recipe_repository.dart
// Domain Layer Repository 인터페이스: 레시피 데이터 작업 계약 정의

import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_list_state.dart';

import '../entities/recipe.dart'; // RecipeEntity 임포트

// abstract class로 Repository 인터페이스 정의
abstract class RecipeRepository {

  // 레시피 목록을 가져오는 메서드 정의
  // Future<List<RecipeEntity>>: 비동기로 List<RecipeEntity>를 반환
  // 또는 실시간 업데이트를 위해 Stream<List<RecipeEntity>> 사용 가능
  Stream<List<RecipeEntity>> getRecipes({RecipeFilterOptions? filterOptions}); // 예시: 실시간 업데이트 스트림

  // 특정 레시피 상세 정보를 가져오는 메서드 정의 (ID로 조회)
  Future<RecipeEntity?> getRecipeDetail(String uid); // 해당 UID 레시피 Entity 반환, 없을 수 있으니 nullable

  // 레시피를 검색하는 메서드 정의 (검색어를 받아서 List<RecipeEntity> 반환)
  Future<List<RecipeEntity>> searchRecipes(String query);

  // 새로운 레시피를 추가하는 메서드 정의 (추가할 RecipeEntity 객체를 받음)
  // Future<String>: 추가된 레시피의 새로운 UID를 반환 (선택 사항)
  Future<String> addRecipe(RecipeEntity recipe);

  // 기존 레시피를 업데이트하는 메서드 정의 (업데이트할 RecipeEntity 객체를 받음 - UID 포함)
  Future<void> updateRecipe(RecipeEntity recipe); // 업데이트는 보통 void 반환

  // 특정 레시피를 삭제하는 메서드 정의 (삭제할 레시피의 UID를 받음)
  Future<void> deleteRecipe(String uid); // 삭제는 보통 void 반환

  // 레시피 목록을 초기화
  Future<void> clearCache();

  // TODO: 필요에 따라 추가적인 데이터 작업 메서드 정의 (예: 좋아요/찜하기 상태 변경, 카테고리 목록 가져오기)
  // 즐겨찾기 상태 변경
  Future<void> toggleFavorite(String uid, bool isFavorite);
}
