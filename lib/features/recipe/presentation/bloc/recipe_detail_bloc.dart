// lib/features/recipe/presentation/bloc/recipe_detail_bloc.dart
import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_recipe_detail_usecase.dart'; // UseCase 임포트

import 'recipe_detail_event.dart';
import 'recipe_detail_state.dart';

class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final GetRecipeDetailUseCase _getRecipeDetailUseCase;

  RecipeDetailBloc(this._getRecipeDetailUseCase) : super(RecipeDetailInitial()) {
    on<GetRecipeDetail>(_onGetRecipeDetail);
  }

  Future<void> _onGetRecipeDetail(GetRecipeDetail event, Emitter<RecipeDetailState> emit) async {
    emit(RecipeDetailLoading()); // 로딩 상태 발행
    try {
      final recipe = await _getRecipeDetailUseCase(event.recipeId); // UseCase 실행
      if (recipe != null) {
        emit(RecipeDetailLoaded(recipe)); // 로딩 완료 상태 발행
      } else {
        emit(RecipeDetailError('레시피를 찾을 수 없습니다.')); // 레시피 없음 에러
      }
    } catch (e) {
      emit(RecipeDetailError('레시피 상세 정보 로딩 실패: ${e.toString()}')); // 에러 상태 발행
    }
  }
}
