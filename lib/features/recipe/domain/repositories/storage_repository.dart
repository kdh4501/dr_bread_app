// lib/features/recipe/domain/repositories/storage_repository.dart
// Domain Layer Repository 인터페이스: 이미지 저장소 작업 계약 정의

// 이미지 파일 타입을 나타내기 위해 dart:io의 File 또는 image_picker의 XFile 사용 가능
// Domain Layer는 특정 패키지에 종속되지 않아야 하지만, 파일 처리를 위해 기본 라이브러리 File 사용
import 'dart:io'; // File 클래스 사용

// abstract class로 StorageRepository 인터페이스 정의
abstract class StorageRepository {

  // 이미지 파일을 받아서 저장소에 업로드하고 다운로드 URL을 반환하는 메서드 정의
  // Future<String>: 업로드된 이미지의 다운로드 URL을 비동기로 반환
  // File imageFile: 업로드할 이미지 파일 객체
  // String path: 저장소에 저장될 경로 (예: 'recipe_images/...')
  Future<String> uploadImage(File imageFile, String path);

  // TODO: 필요에 따라 이미지 삭제 등 추가적인 저장소 작업 메서드 정의
  Future<void> deleteImage(String imageUrl);
}
