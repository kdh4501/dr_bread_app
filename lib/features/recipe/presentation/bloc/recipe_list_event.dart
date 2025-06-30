import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_list_state.dart';
import 'package:equatable/equatable.dart';

abstract class RecipeListEvent extends Equatable {
  const RecipeListEvent();
  @override
  List<Object?> get props => [];
}

class FetchRecipes extends RecipeListEvent {} // 레시피 목록 초기 조회/새로고침 이벤트

class SearchRecipes extends RecipeListEvent { // 레시피 검색 이벤트
  final String query;
  const SearchRecipes(this.query);
  @override
  List<Object?> get props => [query];
}

class ApplyFilter extends RecipeListEvent { // 레시피 필터링 이벤트
  final RecipeFilterOptions filterOptions;
  const ApplyFilter(this.filterOptions);
  @override
  List<Object?> get props => [filterOptions];
}