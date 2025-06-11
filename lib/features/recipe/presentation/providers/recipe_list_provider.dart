import 'dart:async';

import 'package:flutter/foundation.dart'; // ChangeNotifier 사용
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
import '../../domain/usecases/get_recipes_usecase.dart'; // GetRecipesUseCase 임포트
import '../../domain/usecases/search_recipes_usecase.dart'; // SearchRecipesUseCase 임포트
// TODO: 다른 UseCase (예: FilterRecipesUseCase) 필요시 임포트

/*
레시피 목록 화면에 필요한 모든 상태(데이터, 로딩 여부, 에러 메시지, 검색어, 필터 조건 등) 관리
 */
class RecipeListProvider with ChangeNotifier { // ChangeNotifier 상속 (with 키워드 사용)
  // Domain Layer의 UseCase들을 생성자로 주입받음
  final GetRecipesUseCase _getRecipesUseCase;
  final SearchRecipesUseCase _searchRecipesUseCase;
  // TODO: 다른 UseCase 주입

  // --- 상태 변수들 ---
  List<RecipeEntity> _recipes = []; // 레시피 목록 데이터
  bool _isLoading = false; // 데이터 로딩 중인지 여부
  String? _errorMessage; // 에러 메시지 (에러 발생 시)
  String _searchQuery = ''; // 현재 검색어
  // TODO: FilterOptions filterOptions; // 필터링 조건 상태 변수

  // Getter들을 통해 외부에서 상태 변수에 접근 가능하게 함 (읽기 전용)
  List<RecipeEntity> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Stream 구독(Stream으로부터 데이터를 받을 때까지 이 구독 상태를 유지)
  StreamSubscription<List<RecipeEntity>>? _recipeSubscription;

  // 생성자: UseCase들을 전달받아 초기화
  RecipeListProvider(this._getRecipesUseCase, this._searchRecipesUseCase) {
    // Provider 생성 시 초기 데이터 로딩 스트림 바로 시작
    // UseCase가 스트림을 반환하므로 생성자에서 바로 구독 시작 가능
    fetchRecipes(); // <-- 생성 시 fetchRecipes() 호출하여 스트림 구독 시작
  }
  // TODO: 다른 UseCase들도 생성자 매개변수로 추가

  // 레시피 목록 데이터 가져오는 함수 (초기 로딩 또는 새로고침 시 호출)
  void fetchRecipes() {
    // 이전 구독이 있다면 취소로 메모리 누수 방지
    _recipeSubscription?.cancel();

    if (_isLoading) return; // 이미 로딩 중이면 중복 호출 방지

    _isLoading = true; // 로딩 시작
    _errorMessage = null; // 이전 에러 메시지 초기화
    notifyListeners(); // 로딩 상태 변경 알림 (UI에서 로딩 스피너 표시 등)

    try {
      // Domain Layer의 GetRecipesUseCase 실행
      final recipeStream = _getRecipesUseCase(); // call() 메서드 호출

      // ↓↓↓↓↓ Stream을 listen() 해서 데이터를 받아와 _recipes 변수 업데이트 ↓↓↓↓↓
      _recipeSubscription = recipeStream.listen( // Stream 구독 시작!
            (listRecipeEntity) { // 스트림에서 새로운 List<RecipeEntity>가 발행될 때마다 이 블록 실행
          // 스트림에서 받은 최신 레시피 목록으로 상태 업데이트
          _recipes = listRecipeEntity;
          _errorMessage = null; // 성공 시 에러 없음
          _isLoading = false; // 첫 데이터 오면 로딩 종료 (선택 사항)
          notifyListeners(); // 상태 변경 알림 (UI 업데이트)

        },
        onError: (error) { // 스트림에서 에러 발생 시 이 블록 실행
          // 에러 발생 시 상태 업데이트
          _errorMessage = '레시피를 불러오는데 실패했습니다: $error';
          _recipes = []; // 에러 발생 시 목록 비우기 (선택 사항)
          _isLoading = false; // 로딩 종료
          notifyListeners(); // 상태 변경 알림
          debugPrint('레시피 스트림 에러 발생: $error');
        },
        onDone: () { // 스트림 종료 시 이 블록 실행 (Firestore 스트림은 보통 종료되지 않음)
          _isLoading = false; // 로딩 종료
          notifyListeners();
          debugPrint('레시피 스트림 종료');
        },
        cancelOnError: true, // 에러 발생 시 자동으로 구독 취소
      );

    } catch (e) {
      // 에러 발생 시
      _errorMessage = '레시피를 불러오는데 실패했습니다: $e'; // 에러 메시지 설정
      _recipes = []; // 에러 발생 시 목록 비우기 (선택 사항)
      debugPrint('레시피 로딩 중 에러 발생: $e'); // 디버깅용 로그
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners(); // 상태 변경 알림 (로딩 종료, 목록/에러 메시지 업데이트)
    }
  }

  // 검색 실행 함수
  Future<void> performSearch(String query) async {
    _searchQuery = query; // 검색어 업데이트

    if (query.isEmpty) {
      // 검색어가 비어있으면 전체 목록 다시 가져오거나 이미 로딩된 전체 목록 사용
      // 여기서는 전체 목록 다시 가져오는 UseCase 호출 (Firestore 쿼리 사용 시)
      // 만약 클라이언트 측 검색이라면 _recipes 변수에서 직접 필터링 로직 수행
      fetchRecipes(); // 검색어 없으면 전체 목록 로드
      return;
    }

    // 검색 실행 시에는 기존 실시간 스트림 구독을 중지하는 것이 일반적
    _recipeSubscription?.cancel();

    if (_isLoading) return; // 이미 다른 로딩 중이면 중복 호출 방지

    _isLoading = true; // 로딩 시작 (검색 로딩)
    _errorMessage = null; // 이전 에러 메시지 초기화
    notifyListeners(); // 로딩 상태 변경 알림

    try {
      // Domain Layer의 SearchRecipesUseCase 실행
      final result = await _searchRecipesUseCase(query); // call() 메서드에 검색어 전달

      _recipes = result; // 검색 결과로 목록 업데이트
      _errorMessage = null; // 성공 시 에러 없음

    } catch (e) {
      // 에러 발생 시
      _errorMessage = '레시피 검색에 실패했습니다: $e'; // 에러 메시지 설정
      _recipes = []; // 에러 발생 시 목록 비우기 (선택 사항)
      debugPrint('레시피 검색 중 에러 발생: $e'); // 디버깅용 로그
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners(); // 상태 변경 알림 (로딩 종료, 목록/에러 메시지 업데이트)
    }
  }

// TODO: 필터링 실행 함수 (필터 옵션 객체를 받아서 처리)
/*
  Future<void> applyFilter(FilterOptions options) async {
     // _filterOptions = options; // 필터 옵션 상태 변수 업데이트
     // ... 필터링 로직 (UseCase 호출 또는 클라이언트 측 필터링)
     // notifyListeners();
  }
  */

// TODO: 필요시 레시피 추가/수정/삭제 후 목록 갱신 로직 추가
// (예: addRecipe 완료 후 fetchRecipes() 다시 호출 또는 _recipes 목록에 직접 추가)

// 위젯 트리에서 제거될 때 호출되어 자원 정리 (StreamSubscription 등)
@override
void dispose() {
  // TODO: StreamSubscription 취소 등 자원 해제 로직
  // ↓↓↓↓↓ Stream 구독 반드시 취소! 메모리 누수 방지 ↓↓↓↓↓
  _recipeSubscription?.cancel();
  // ↑↑↑↑↑ Provider가 사라질 때 스트림 연결을 끊어줌 ↑↑↑↑↑
  super.dispose();
}
}

// TODO: 필터 옵션 등을 위한 데이터 클래스 필요시 정의
// class FilterOptions { ... }
