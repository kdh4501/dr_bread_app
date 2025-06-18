// lib/features/recipe/domain/usecases/upload_image_usecase.dart
// Domain Layer UseCase: 이미지 업로드 비즈니스 로직

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
    // 비즈니스 로직 수행 (필요하다면 여기서 파일 유효성 검사, 경로 생성 규칙 적용 등)
    // 예: 파일 크기 제한 체크

    // Repository에게 이미지 업로드 요청 위임
    final downloadUrl = await repository.uploadImage(imageFile, path);

    // 다운로드 URL 반환
    return downloadUrl;
  }

// TODO: 필요에 따라 이미지 삭제 UseCase 등 추가
}
