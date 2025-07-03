// 필터링 옵션을 위한 데이터 클래스 (Domain Layer에 정의하는 것이 더 적합)
import 'package:equatable/equatable.dart';

import '../../domain/entities/recipe.dart';

class RecipeFilterOptions extends Equatable {
  final String? category;
  final String? difficulty; // 예시: '쉬움', '보통', '어려움'
  final int? maxPrepTimeMinutes; // 예시: 최대 준비 시간 (분)
  final bool? showMyRecipesOnly;

  const RecipeFilterOptions({
    this.category,
    this.difficulty,
    this.maxPrepTimeMinutes,
    this.showMyRecipesOnly,
  });

  RecipeFilterOptions copyWith({
    String? category,
    String? difficulty,
    int? maxPrepTimeMinutes,
    bool? showMyRecipesOnly,
  }) {
    return RecipeFilterOptions(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      maxPrepTimeMinutes: maxPrepTimeMinutes ?? this.maxPrepTimeMinutes,
      showMyRecipesOnly: showMyRecipesOnly ?? this.showMyRecipesOnly,
    );
  }

  @override
  List<Object?> get props => [category, difficulty, maxPrepTimeMinutes];
}

abstract class RecipeListState extends Equatable {
  final List<RecipeEntity> recipes;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final RecipeFilterOptions filterOptions; // 필터링 옵션

  const RecipeListState({
    this.recipes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filterOptions = const RecipeFilterOptions(),
  });

  @override
  List<Object?> get props => [recipes, isLoading, errorMessage, searchQuery, filterOptions];
}

class RecipeListInitial extends RecipeListState {} // 초기 상태

class RecipeListLoading extends RecipeListState { // 로딩 중 상태
  const RecipeListLoading({
    required super.recipes,
    required super.searchQuery,
    required super.filterOptions,
  }) : super(
      isLoading: true,
      errorMessage: null
  );
}

class RecipeListLoaded extends RecipeListState { // 목록 로딩 완료 상태
  const RecipeListLoaded({
    required super.recipes,
    required super.searchQuery,
    required super.filterOptions,
  }) : super(
    isLoading: false,
    errorMessage: null,
  );
}

class RecipeListError extends RecipeListState { // 에러 상태
  const RecipeListError({
    required super.errorMessage,
    required super.recipes, // 에러 발생 시에도 기존 목록은 유지할 수 있음
    required super.searchQuery,
    required super.filterOptions,
  }) : super(
      isLoading: false,
  );
}