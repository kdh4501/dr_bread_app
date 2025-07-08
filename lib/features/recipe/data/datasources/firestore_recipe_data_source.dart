// lib/features/recipe/data/datasources/firestore_recipe_data_source.dart
// Data Layer DataSource: 파이어베이스 Firestore와 직접 통신

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore SDK 사용
import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_list_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../models/recipe_model.dart'; // RecipeModel 임포트

// Firestore 데이터 소스 인터페이스 (선택 사항, 개인 프로젝트에서는 구현체만 만들어도 됨)
// abstract class RecipeDataSource {
//   Stream<List<RecipeModel>> getRecipeStream();
//   Future<RecipeModel?> getRecipe(String uid);
//   Future<List<RecipeModel>> searchRecipes(String query);
//   Future<String> addRecipe(RecipeModel recipe);
//   Future<void> updateRecipe(RecipeModel recipe);
//   Future<void> deleteRecipe(String uid);
// }


// Firestore 데이터 소스 구현체
// class FirestoreRecipeDataSource implements RecipeDataSource { // 인터페이스 구현 시
class FirestoreRecipeDataSource { // 인터페이스 없이 바로 구현 시

  // FirebaseFirestore 인스턴스에 의존 (main.dart에서 주입받음)
  final FirebaseFirestore _firestore;

  // 생성자로 FirebaseFirestore 인스턴스를 주입받음
  FirestoreRecipeDataSource(this._firestore);

  // Firestore 컬렉션 참조 (레시피 데이터가 저장될 컬렉션 이름)
  // TODO: 컬렉션 이름은 상수로 관리하는 것이 좋음 (core/constants/app_constants.dart 등)
  final CollectionReference _recipesCollection = FirebaseFirestore.instance.collection('recipes'); // TODO: _firestore 인스턴스 사용하도록 수정 필요!


  // 모든 레시피 목록을 실시간 스트림으로 가져오는 메서드
  // Stream<List<RecipeModel>> 반환
  Stream<QuerySnapshot> getRecipeStream({RecipeFilterOptions? filterOptions}) {
    Query query = _recipesCollection;

    // '내 레시피만 보기' 필터 적용
    if (filterOptions?.showMyRecipesOnly == true) {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid; // 현재 사용자 UID 가져오기
      if (currentUserUid != null) {
        query = query.where('authorUid', isEqualTo: currentUserUid); // authorUid 필터 추가
      } else {
        // 사용자가 로그인되어 있지 않는데 '내 레시피만 보기' 요청 시 빈 스트림 반환
        // 주의: 이 경우 Firestore 쿼리 권한 에러가 발생할 수 있으므로, 해당 규칙을 허용하거나
        // UI에서 로그인되지 않은 사용자에게는 '내 레시피만 보기' 옵션을 비활성화해야 함.
        debugPrint('FirestoreRecipeDataSource: User not logged in, but trying to show only my recipes. Returning empty stream.');
        return _firestore.collection('empty_recipes').snapshots(); // 빈 QuerySnapshot 반환
      }

      if (filterOptions?.showFavoritesOnly == true) {
        query = query.where('isFavorite', isEqualTo: true); // isFavorite 필터 추가
      }
    }
    return query.snapshots();
  }

  // 특정 레시피 상세 정보를 ID로 가져오는 메서드
  // Future<RecipeModel?> 반환
  Future<RecipeModel?> getRecipe(String uid) async {
    try {
      // Firestore 문서 참조 가져오기
      final docSnapshot = await _recipesCollection.doc(uid).get();

      // 문서가 존재하면 RecipeModel로 변환하여 반환, 없으면 null 반환
      if (docSnapshot.exists) {
        return RecipeModel.fromJson(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
      } else {
        return null; // 해당 ID의 문서가 없음
      }
    } catch (e) {
      // Firestore 통신 중 발생한 에러 처리
      debugPrint('Error fetching recipe from Firestore: $e');
      // 에러를 다시 던져서 Repository나 UseCase에서 처리하도록 함
      rethrow;
    }
  }

  // 레시피를 검색하는 메서드 (검색어 기반 쿼리)
  // Future<List<RecipeModel>> 반환
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      // TODO: Firestore 검색 쿼리 구현 (Firestore는 복잡한 텍스트 검색 기능이 제한적)
      // 예시: 제목 필드가 검색어로 시작하는 문서 찾기 (Firestore는 startsWith 쿼리 직접 지원 안 함)
      // 실제 구현은 더 복잡하거나 다른 검색 솔루션 필요
      // 간단한 예시 (제목에 검색어가 포함된 모든 문서 가져와서 클라이언트에서 필터링 - 비효율적)
      // 또는 제목 필드에 대한 인덱스를 만들고 특정 조건으로 쿼리 (예: where('title', isGreaterThanOrEqualTo: query).where('title', isLessThan: query + '\uf8ff'))

      // 현재는 간단히 모든 문서 가져와서 제목에 검색어 포함 여부로 필터링하는 예시 (성능 주의)
      // 실제 앱에서는 검색어에 맞는 효율적인 Firestore 쿼리 또는 다른 검색 솔루션 사용 필수
      final querySnapshot = await _recipesCollection.get(); // 모든 문서 가져오기 (비효율적!)

      final allRecipes = querySnapshot.docs.map((doc) {
        return RecipeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // 클라이언트 측에서 제목에 검색어가 포함된 레시피 필터링
      final searchResults = allRecipes.where((recipe) {
        // 검색어는 소문자로 변환하여 대소문자 구분 없이 검색
        return recipe.title.toLowerCase().contains(query.toLowerCase());
      }).toList();

      return searchResults;

      // TODO: 만약 Firestore 쿼리로 검색을 구현한다면 (인덱스 필요)
      /*
      final querySnapshot = await _recipesCollection
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff') // startsWith 유사 쿼리
          // TODO: 다른 필드 검색 시 OR 조건은 Firestore에서 직접 지원 안 함 (별도 처리 필요)
          .get();

      return querySnapshot.docs.map((doc) {
         return RecipeModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      */

    } catch (e) {
      debugPrint('Error searching recipes in Firestore: $e');
      rethrow;
    }
  }


  // 새로운 레시피를 Firestore에 추가하는 메서드
  // Future<String> (새로 생성된 문서 ID) 반환
  Future<String> addRecipe(RecipeModel recipe) async {
    try {
      // RecipeModel 객체를 Firestore 저장을 위한 Map 데이터로 변환
      final recipeMap = recipe.toJson();

      // Firestore에 문서 추가 (ID 자동 생성)
      // final docRef = await _recipesCollection.add(recipeMap);
      final docRef = await _recipesCollection
          .add(recipeMap)
          .timeout(Duration(seconds: 5));
      debugPrint('FirestoreRecipeDataSource: Firestore add finished. Doc ID: ${docRef.id}'); // <-- Firestore 호출 완료 로그

      // 새로 생성된 문서의 ID 반환
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('FirestoreRecipeDataSource: FirebaseException in addRecipe: ${e.code} - ${e.message}'); // <-- Firebase 에러 로그
      rethrow; // 에러 다시 던짐
    } on TimeoutException catch (e) {
      debugPrint('FirestoreRecipeDataSource: TimeoutException in addRecipe: $e');
      throw Exception('Firestore 저장 요청 시간 초과'); // 사용자에게 보여줄 에러 메시지로 변환
    } catch (e, s) {
      debugPrint('FirestoreRecipeDataSource: Generic error in addRecipe: $e'); // <-- 기타 에러 로그
      debugPrint('❌ Caught error: $e\nStack: $s');
      rethrow; // 에러 다시 던짐
    }
  }

  // 기존 레시피를 Firestore에서 업데이트하는 메서드
  // Future<void> 반환
  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      // RecipeModel 객체를 Firestore 저장을 위한 Map 데이터로 변환
      final recipeMap = recipe.toJson();

      // 특정 ID의 문서 업데이트
      await _recipesCollection.doc(recipe.id).update(recipeMap);
    } catch (e) {
      debugPrint('Error updating recipe in Firestore: $e');
      rethrow;
    }
  }

  // 특정 레시피를 Firestore에서 삭제하는 메서드
  // Future<void> 반환
  Future<void> deleteRecipe(String uid) async {
    try {
      // 특정 ID의 문서 삭제
      await _recipesCollection.doc(uid).delete();
    } catch (e) {
      debugPrint('Error deleting recipe from Firestore: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    await _firestore.clearPersistence(); // Firestore 로컬 캐시 지우기
    debugPrint('Firestore cache cleared.');
  }

  Future<void> updateRecipeField(String uid, String field, dynamic value) async { // 특정 필드 업데이트
    try {
      await _recipesCollection.doc(uid).update({field: value});
      debugPrint('FirestoreRecipeDataSource: Updated field $field for recipe $uid to $value');
    } catch (e) {
      debugPrint('FirestoreRecipeDataSource: Failed to update field $field for recipe $uid: $e');
      rethrow;
    }
  }

// TODO: 필요에 따라 이미지 업로드/삭제 등 Storage 관련 메서드 추가 (별도 DataSource로 분리 가능)
}
