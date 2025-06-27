// lib/features/recipe/presentation/bloc/recipe_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class RecipeDetailEvent extends Equatable {
  const RecipeDetailEvent();
  @override
  List<Object?> get props => [];
}

class GetRecipeDetail extends RecipeDetailEvent { // 상세 정보 조회 요청 이벤트
  final String recipeId;
  const GetRecipeDetail(this.recipeId);
  @override
  List<Object?> get props => [recipeId];
}
