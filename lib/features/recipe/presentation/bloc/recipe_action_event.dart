// lib/features/recipe/presentation/bloc/recipe_action_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
import 'dart:io'; // File 임포트 (이미지 업로드용)
import 'package:image_picker/image_picker.dart'; // XFile 임포트 (이미지 업로드용)

abstract class RecipeActionEvent extends Equatable {
  const RecipeActionEvent();
  @override
  List<Object?> get props => [];
}
/*
  RecipeEntity 자체에 category와 tags가 포함되므로, 이벤트에 별도로 추가할 필요는 없음
  RecipeEntity를 이벤트에 전달하면 됨
 */
class AddRecipeRequested extends RecipeActionEvent { // 레시피 추가 요청 이벤트
  final RecipeEntity recipe;
  final XFile? imageFile; // 이미지 파일 (선택 사항)
  const AddRecipeRequested({required this.recipe, this.imageFile});
  @override
  List<Object?> get props => [recipe, imageFile];
}

class UpdateRecipeRequested extends RecipeActionEvent { // 레시피 편집 요청 이벤트
  final RecipeEntity recipe;
  final XFile? imageFile; // 이미지 파일 (선택 사항)
  final bool deleteExistingImage; // 기존 이미지 삭제 여부 플래그
  final String? currentImageUrl;  // 현재 레시피의 이미지 URL

  const UpdateRecipeRequested({
    required this.recipe,
    this.imageFile,
    this.deleteExistingImage = false,
    this.currentImageUrl,
  });
  @override
  List<Object?> get props => [recipe, imageFile, deleteExistingImage, currentImageUrl];
}

class DeleteRecipeRequested extends RecipeActionEvent { // 레시피 삭제 요청 이벤트
  final String uid; // 삭제할 레시피 UID
  final String? imageUrl; // 삭제할 이미지 URL (선택 사항)
  const DeleteRecipeRequested({required this.uid, this.imageUrl});
  @override
  List<Object?> get props => [uid, imageUrl];
}
