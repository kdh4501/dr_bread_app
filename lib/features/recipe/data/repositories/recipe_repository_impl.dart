// lib/features/recipe/data/repositories/recipe_repository_impl.dart
// Data Layer Repository 구현체: Domain Layer Repository 인터페이스를 implements

import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 관련 에러 처리를 위해 필요할 수 있음
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/recipe.dart'; // Domain Entity 임포트
import '../../domain/repositories/recipe_repository.dart'; // Domain Repository Interface 임포트
import '../../presentation/bloc/recipe_list_state.dart';
import '../datasources/firestore_recipe_data_source.dart'; // FirestoreDataSource 임포트
import '../models/recipe_model.dart'; // RecipeModel 임포트 (Entity <-> Model 변환용)

// RecipeRepository 인터페이스를 구현 (implements)
class RecipeRepositoryImpl implements RecipeRepository {
  // DataSource에 의존 (실제 데이터 처리 위임)
  final FirestoreRecipeDataSource dataSource;

  // 생성자로 DataSource 구현체를 주입받음
  RecipeRepositoryImpl(this.dataSource);

  // Domain Layer에서 정의한 getRecipes() 메서드 구현
  // Stream<List<RecipeEntity>> 반환
  @override
  Stream<List<RecipeEntity>> getRecipes({RecipeFilterOptions? filterOptions}) {
    // DataSource에서 Firestore 데이터 스트림(Stream<List<RecipeModel>>)을 가져온 후,
    // 각 RecipeModel을 RecipeEntity로 변환하여 새로운 스트림(Stream<List<RecipeEntity>>)으로 반환
    // map 함수를 사용하여 Stream의 각 이벤트(List<RecipeModel>)를 변환
    return dataSource.getRecipeStream(filterOptions: filterOptions).map((snapshot) {
      // List<RecipeModel> -> List<RecipeEntity> 변환 로직
      return snapshot.docs.map((doc) {
        // doc.data()는 Map<String, dynamic> 반환, doc.id는 문서 ID 반환
        return RecipeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id).toEntity();
      }).toList();
    });
  }

  // Domain Layer에서 정의한 getRecipeDetail() 메서드 구현
  // Future<RecipeEntity?> 반환
  @override
  Future<RecipeEntity?> getRecipeDetail(String uid) async {
    try {
      // DataSource에서 특정 ID의 Firestore 데이터(RecipeModel)를 가져옴
      final recipeModel = await dataSource.getRecipe(uid);
      // 가져온 RecipeModel이 null이 아니면 RecipeEntity로 변환하여 반환
      return recipeModel?.toEntity();
    } catch (e) {
      // DataSource에서 발생한 에러를 여기서 잡거나 다시 던질 수 있음
      // 예: FirestoreException 발생 시
      if (e is FirebaseException) {
        // Firebase 관련 에러 처리 또는 로깅
        debugPrint('FirestoreException in getRecipeDetail: ${e.message}');
        // throw CustomAppException('데이터 조회 중 오류 발생'); // 커스텀 에러로 변환하여 던지기
      }
      // 다른 종류의 에러는 그대로 던지거나 처리
      rethrow; // 잡은 에러를 다시 던짐
    }
  }

  // Domain Layer에서 정의한 searchRecipes() 메서드 구현
  // Future<List<RecipeEntity>> 반환
  @override
  Future<List<RecipeEntity>> searchRecipes(String query) async {
    try {
      // DataSource에서 검색어로 쿼리 실행하여 List<RecipeModel>을 가져옴
      final listRecipeModel = await dataSource.searchRecipes(query);
      // List<RecipeModel> -> List<RecipeEntity> 변환하여 반환
      return listRecipeModel.map((model) => model.toEntity()).toList();
    } catch (e) {
      // 검색 중 발생한 에러 처리
      rethrow;
    }
  }

  // Domain Layer에서 정의한 addRecipe() 메서드 구현
  // Future<String> (새로 생성된 UID) 반환
  @override
  Future<String> addRecipe(RecipeEntity recipe) async {
    debugPrint('RecipeRepositoryImpl.addRecipe called.');
    try {
      // Domain Layer의 RecipeEntity를 Data Layer의 RecipeModel로 변환 (저장하기 위해)
      final recipeModel = RecipeModel.fromEntity(recipe); // TODO: Model에 fromEntity 팩토리 추가 필요
      debugPrint('RecipeRepositoryImpl: Entity converted to Model.');

      debugPrint('RecipeRepositoryImpl: Calling dataSource.addRecipe...'); // <-- DataSource 호출 전 로그
      // DataSource에게 데이터 추가 요청 위임
      // DataSource는 Firestore에 저장하고 생성된 UID를 반환
      final newRecipeId = await dataSource.addRecipe(recipeModel); // <-- 여기서 에러 발생 가능성
      debugPrint('RecipeRepositoryImpl: dataSource.addRecipe finished. New ID: $newRecipeId'); // <-- DataSource 호출 완료 로그
      return newRecipeId;
    } catch (e) {
      // 데이터 추가 중 발생한 에러 처리
      rethrow;
    }
  }

  // Domain Layer에서 정의한 updateRecipe() 메서드 구현
  // Future<void> 반환
  @override
  Future<void> updateRecipe(RecipeEntity recipe) async {
    try {
      // Domain Layer의 RecipeEntity를 Data Layer의 RecipeModel로 변환 (업데이트하기 위해)
      final recipeModel = RecipeModel.fromEntity(recipe);
      // DataSource에게 데이터 업데이트 요청 위임
      await dataSource.updateRecipe(recipeModel);
    } catch (e) {
      // 데이터 업데이트 중 발생한 에러 처리
      rethrow;
    }
  }

  // Domain Layer에서 정의한 deleteRecipe() 메서드 구현
  // Future<void> 반환
  @override
  Future<void> deleteRecipe(String uid) async {
    try {
      // DataSource에게 데이터 삭제 요청 위임 (UID 전달)
      await dataSource.deleteRecipe(uid);
    } catch (e) {
      // 데이터 삭제 중 발생한 에러 처리
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await dataSource.clearCache();
  }

  @override
  Future<void> toggleFavorite(String uid, bool isFavorite) async {
    await dataSource.updateRecipeField(uid, 'isFavorite', isFavorite);
  }

// TODO: 필요에 따라 추가적인 데이터 작업 메서드 구현
}
