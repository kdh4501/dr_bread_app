// lib/features/recipe/presentation/bloc/recipe_action_state.dart
import 'package:equatable/equatable.dart';

abstract class RecipeActionState extends Equatable {
  const RecipeActionState();
  @override
  List<Object?> get props => [];
}

class RecipeActionInitial extends RecipeActionState {} // 초기 상태
class RecipeActionLoading extends RecipeActionState {} // 작업 로딩 중
class RecipeActionSuccess extends RecipeActionState { // 작업 성공
  final String? message; // 성공 메시지 (선택 사항)
  final String? id; // 새로 생성된 레시피 ID
  const RecipeActionSuccess({this.message, this.id});
  @override
  List<Object?> get props => [message, id];
}
class RecipeActionFailure extends RecipeActionState { // 작업 실패
  final String message; // 에러 메시지
  const RecipeActionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
