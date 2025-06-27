// lib/features/recipe/presentation/bloc/recipe_detail_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';

abstract class RecipeDetailState extends Equatable {
  const RecipeDetailState();
  @override
  List<Object?> get props => [];
}

class RecipeDetailInitial extends RecipeDetailState {} // 초기 상태
class RecipeDetailLoading extends RecipeDetailState {} // 로딩 중 상태
class RecipeDetailLoaded extends RecipeDetailState { // 상세 정보 로딩 완료
  final RecipeEntity recipe;
  const RecipeDetailLoaded(this.recipe);
  @override
  List<Object?> get props => [recipe];
}
class RecipeDetailError extends RecipeDetailState { // 에러 상태
  final String message;
  const RecipeDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
