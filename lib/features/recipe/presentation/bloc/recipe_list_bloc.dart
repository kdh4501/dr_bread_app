import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_list_event.dart';
import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_list_state.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes_usecase.dart';
import '../../domain/usecases/search_recipes_usecase.dart';

final getIt = GetIt.instance; // getIt 인스턴스 가져오기

class RecipeListBloc extends Bloc<RecipeListEvent, RecipeListState> {
  final GetRecipesUseCase _getRecipesUseCase;
  final SearchRecipesUseCase _searchRecipesUseCase;
  // TODO: FilterRecipesUseCase _filterRecipesUseCase;

  StreamSubscription<List<RecipeEntity>>? _recipesSubscription; // 레시피 스트림 구독

  RecipeListBloc(this._getRecipesUseCase, this._searchRecipesUseCase) : super(RecipeListInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
    on<SearchRecipes>(_onSearchRecipes);
    on<ApplyFilter>(_onApplyFilter);

    // Bloc 생성 시 초기 데이터 로딩 (FetchRecipes 이벤트 추가)
    add(FetchRecipes());
  }

  // 레시피 목록 초기 조회/새로고침 이벤트 핸들러
  Future<void> _onFetchRecipes(FetchRecipes event, Emitter<RecipeListState> emit) async {
    _recipesSubscription?.cancel(); // 이전 구독 취소

    emit(RecipeListLoading(recipes: state.recipes, searchQuery: state.searchQuery, filterOptions: state.filterOptions)); // 로딩 상태 발행

    try {
      // UseCase에서 스트림 가져오기 (필터링 조건이 있다면 UseCase에서 처리)
      final recipeStream = _getRecipesUseCase(); // 현재는 필터링 없는 전체 목록 스트림

      _recipesSubscription = recipeStream.listen(
            (recipes) {
          // 스트림에서 받은 데이터로 상태 업데이트
          emit(RecipeListLoaded(recipes: recipes, searchQuery: state.searchQuery, filterOptions: state.filterOptions));
        },
        onError: (error) {
          emit(RecipeListError(errorMessage: '레시피를 불러오는데 실패했습니다: $error', recipes: state.recipes, searchQuery: state.searchQuery, filterOptions: state.filterOptions));
        },
      );
    } catch (e) {
      emit(RecipeListError(errorMessage: '레시피 로딩 중 에러 발생: $e', recipes: state.recipes, searchQuery: state.searchQuery, filterOptions: state.filterOptions));
    }
  }

  // 레시피 검색 이벤트 핸들러
  Future<void> _onSearchRecipes(SearchRecipes event, Emitter<RecipeListState> emit) async {
    _recipesSubscription?.cancel(); // 검색 시 실시간 스트림 구독 취소

    emit(RecipeListLoading(recipes: state.recipes, searchQuery: event.query, filterOptions: state.filterOptions)); // 로딩 상태 발행

    try {
      final searchResults = await _searchRecipesUseCase(event.query); // 검색 UseCase 실행
      emit(RecipeListLoaded(recipes: searchResults, searchQuery: event.query, filterOptions: state.filterOptions)); // 검색 결과로 상태 업데이트
    } catch (e) {
      emit(RecipeListError(errorMessage: '레시피 검색에 실패했습니다: $e', recipes: state.recipes, searchQuery: event.query, filterOptions: state.filterOptions));
    }
  }

  // 레시피 필터링 이벤트 핸들러
  Future<void> _onApplyFilter(ApplyFilter event, Emitter<RecipeListState> emit) async {
    _recipesSubscription?.cancel(); // 필터링 시 실시간 스트림 구독 취소

    emit(RecipeListLoading(recipes: state.recipes, searchQuery: state.searchQuery, filterOptions: event.filterOptions)); // 로딩 상태 발행

    try {
      // TODO: FilterRecipesUseCase를 사용하거나, GetRecipesUseCase에 필터링 조건을 전달
      // 현재 GetRecipesUseCase는 필터링 조건을 받지 않으므로, Repository/UseCase 수정 필요
      // 또는 클라이언트 측에서 필터링 (비효율적)
      final filteredResults = await _getRecipesUseCase().first; // 일단 전체 가져와서 클라이언트에서 필터링
      final finalResults = filteredResults.where((recipe) {
        bool matchesCategory = event.filterOptions.category == null || (recipe.category != null && recipe.category == event.filterOptions.category);
        // TODO: 다른 필터링 조건 추가 (난이도, 시간 등)
        return matchesCategory;
      }).toList();

      emit(RecipeListLoaded(recipes: finalResults, searchQuery: state.searchQuery, filterOptions: event.filterOptions)); // 필터링 결과로 상태 업데이트
    } catch (e) {
      emit(RecipeListError(errorMessage: '레시피 필터링에 실패했습니다: $e', recipes: state.recipes, searchQuery: state.searchQuery, filterOptions: event.filterOptions));
    }
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel(); // Bloc이 dispose될 때 스트림 구독 취소
    return super.close();
  }
}