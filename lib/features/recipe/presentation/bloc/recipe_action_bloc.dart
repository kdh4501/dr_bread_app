// lib/features/recipe/presentation/bloc/recipe_action_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'dart:io'; // File 클래스 사용
import 'package:firebase_auth/firebase_auth.dart'; // 사용자 UID 가져오기용

import '../../../../core/constants/app_contstants.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/add_recipe_usecase.dart';
import '../../domain/usecases/update_recipe_usecase.dart';
import '../../domain/usecases/delete_recipe_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';

import 'recipe_action_event.dart';
import 'recipe_action_state.dart';

final getIt = GetIt.instance; // getIt 인스턴스 가져오기

class RecipeActionBloc extends Bloc<RecipeActionEvent, RecipeActionState> {
  final AddRecipeUseCase _addRecipeUseCase;
  final UpdateRecipeUseCase _updateRecipeUseCase;
  final DeleteRecipeUseCase _deleteRecipeUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  RecipeActionBloc(
      this._addRecipeUseCase,
      this._updateRecipeUseCase,
      this._deleteRecipeUseCase,
      this._uploadImageUseCase,
      ) : super(RecipeActionInitial()) {
    on<AddRecipeRequested>(_onAddRecipeRequested);
    on<UpdateRecipeRequested>(_onUpdateRecipeRequested);
    on<DeleteRecipeRequested>(_onDeleteRecipeRequested);
  }

  // 레시피 추가 요청 이벤트 핸들러
  Future<void> _onAddRecipeRequested(AddRecipeRequested event, Emitter<RecipeActionState> emit) async {
    emit(RecipeActionLoading()); // 로딩 상태 발행
    try {
      String? imageUrl = event.recipe.photoUrl; // 기존 이미지 URL (편집 모드에서 전달될 수 있음)

      // 이미지 파일이 있다면 업로드
      if (event.imageFile != null) {
        final imageFile = File(event.imageFile!.path);
        final String uploadPath = '$kRecipeImagesStoragePath/${getIt<FirebaseAuth>().currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _uploadImageUseCase(imageFile, uploadPath);
      }

      // RecipeEntity에 최종 이미지 URL 반영
      final recipeToSave = event.recipe.copyWith(
        photoUrl: imageUrl,
        authorUid: getIt<FirebaseAuth>().currentUser?.uid, // 작성자 UID 추가
        createdAt: DateTime.now(), // 생성 시간 추가 (DataSource에서 서버 시간으로 덮어쓸 수 있음)
        updatedAt: DateTime.now(), // 업데이트 시간 추가
      );

      final newRecipeId = await _addRecipeUseCase(recipeToSave); // UseCase 실행
      emit(RecipeActionSuccess(message: '레시피가 추가되었습니다!', id: newRecipeId)); // 성공 상태 발행
    } catch (e) {
      emit(RecipeActionFailure('레시피 추가 실패: ${e.toString()}')); // 실패 상태 발행
    }
  }

  // 레시피 편집 요청 이벤트 핸들러
  Future<void> _onUpdateRecipeRequested(UpdateRecipeRequested event, Emitter<RecipeActionState> emit) async {
    emit(RecipeActionLoading()); // 로딩 상태 발행
    try {
      String? finalImageUrl = event.currentImageUrl;

      if (event.imageFile != null) {  // 1. 새 이미지를 선택한 경우
        final imageFile = File(event.imageFile!.path);
        final String uploadPath = '$kRecipeImagesStoragePath/${getIt<FirebaseAuth>().currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        finalImageUrl = await _uploadImageUseCase(imageFile, uploadPath); // 새 이미지 업로드
        debugPrint('RecipeActionBloc: New image uploaded. URL: $finalImageUrl');

        // 기존 이미지가 있었다면 삭제 (새 이미지로 교체 시)
        if (event.currentImageUrl != null && event.currentImageUrl!.isNotEmpty) {
          try {
            await _uploadImageUseCase.repository.deleteImage(event.currentImageUrl!);
            debugPrint('RecipeActionBloc: Old image deleted from Storage: ${event.currentImageUrl}');
          } catch (e) {
            debugPrint('RecipeActionBloc: Failed to delete old image: $e'); // 삭제 실패는 경고만
          }
        } else if (event.deleteExistingImage) { // 2. 기존 이미지를 명시적으로 삭제 요청한 경우
          if (event.currentImageUrl != null && event.currentImageUrl!.isNotEmpty) {
            await _uploadImageUseCase.repository.deleteImage(event.currentImageUrl!);
            debugPrint('RecipeActionBloc: Existing image explicitly deleted. URL: ${event.currentImageUrl}');
          }
          finalImageUrl = null; // 이미지 삭제했으니 URL은 null
        }
      } else {  // 3. 새 이미지도 없고, 삭제 요청도 없는 경우 (기존 이미지 유지)
        finalImageUrl = event.currentImageUrl;  // 기존 이미지 URL 유지
        debugPrint('RecipeActionBloc: No new image, no delete request. Keeping existing image. URL: $finalImageUrl');
      }

      // RecipeEntity에 최종 이미지 URL 반영 및 업데이트 시간 추가
      final recipeToUpdate = event.recipe.copyWith(
        photoUrl: finalImageUrl,
        updatedAt: DateTime.now(), // 업데이트 시간 추가
      );

      await _updateRecipeUseCase(recipeToUpdate); // UseCase 실행
      emit(RecipeActionSuccess(message: '레시피가 수정되었습니다!')); // 성공 상태 발행
    } catch (e) {
      debugPrint('RecipeActionBloc: Error updating recipe: $e');
      emit(RecipeActionFailure('레시피 수정 실패: ${e.toString()}')); // 실패 상태 발행
    }
  }

  // 레시피 삭제 요청 이벤트 핸들러
  Future<void> _onDeleteRecipeRequested(DeleteRecipeRequested event, Emitter<RecipeActionState> emit) async {
    debugPrint('RecipeActionBloc: _onDeleteRecipeRequested called.');
    emit(RecipeActionLoading()); // 로딩 상태 발행
    try {
      // 이미지 URL이 있다면 Storage에서 먼저 삭제
      if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
        await _uploadImageUseCase.repository.deleteImage(event.imageUrl!); // StorageRepository의 deleteImage 호출
      }
      await _deleteRecipeUseCase(event.uid); // UseCase 실행
      emit(RecipeActionSuccess(message: '레시피가 삭제되었습니다!')); // 성공 상태 발행
    } catch (e) {
      emit(RecipeActionFailure('레시피 삭제 실패: ${e.toString()}')); // 실패 상태 발행
    }
  }
}
