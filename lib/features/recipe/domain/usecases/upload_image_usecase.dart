// lib/features/recipe/domain/usecases/upload_image_usecase.dart
// Domain Layer UseCase: 이미지 업로드 비즈니스 로직

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../repositories/storage_repository.dart'; // StorageRepository 인터페이스 임포트
import 'dart:io'; // File 클래스 사용
// TODO: image_picker의 XFile 사용 시 import 'package:image_picker/image_picker.dart';

class UploadImageUseCase {
  // StorageRepository 인터페이스에 의존
  final StorageRepository repository;

  // 생성자로 StorageRepository 구현체를 주입받음
  UploadImageUseCase(this.repository);

  // UseCase 실행 메서드: 업로드할 이미지 파일과 저장 경로를 입력으로 받음
  // Future<String>: 업로드된 이미지의 다운로드 URL을 비동기로 반환
  // File imageFile: 업로드할 이미지 파일 객체 (또는 XFile)
  // String path: Storage에 저장될 경로 (예: 'recipe_images/...')
  Future<String> call(File imageFile, String path) async { // call() 메서드 사용
    debugPrint('UploadImageUseCase: Called with path: $path, original file size: ${imageFile.lengthSync()} bytes.');

    final targetPath = '${imageFile.path}_compressed.jpg';

    // 이미지를 압축하고 파일로 저장
    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path, // 원본 이미지의 절대 경로
      targetPath, // 압축된 이미지를 저장할 경로
      quality: 80, // 이미지 품질 (0-100, 80-90이 일반적이고 좋은 품질을 유지하면서 파일 크기 감소)
      minWidth: 1024, // 최소 너비 (원본보다 크면 축소, 작으면 유지)
      minHeight: 1024, // 최소 높이 (원본보다 크면 축소, 작으면 유지)
      format: CompressFormat.jpeg, // 압축 포맷 (JPEG 권장)
    );

    File fileToUpload = imageFile; // 기본적으로 원본 파일 사용
    if (compressedXFile != null) {
      fileToUpload = File(compressedXFile.path); // 압축된 파일이 생성되었으면 압축된 파일 사용
      debugPrint('UploadImageUseCase: Image compressed from ${imageFile.lengthSync()} to ${fileToUpload.lengthSync()} bytes.');
    } else {
      debugPrint('UploadImageUseCase: Image compression failed or returned null. Using original file.');
    }

    // Repository에게 이미지 업로드 요청 위임
    final downloadUrl = await repository.uploadImage(fileToUpload, path);

    // 압축된 임시 파일 삭제 (업로드 후)
    if (compressedXFile != null && await fileToUpload.exists()) {
      try {
        await fileToUpload.delete();
        debugPrint('UploadImageUseCase: Compressed temporary file deleted.');
      } catch (e) {
        debugPrint('UploadImageUseCase: Failed to delete compressed temporary file: $e');
      }
    }

    // 다운로드 URL 반환
    return downloadUrl;
  }

// TODO: 필요에 따라 이미지 삭제 UseCase 등 추가
}
