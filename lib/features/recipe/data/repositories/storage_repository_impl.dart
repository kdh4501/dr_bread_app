// lib/features/recipe/data/repositories/storage_repository_impl.dart
// Data Layer Repository 구현체: Domain Layer StorageRepository 인터페이스를 implements

import 'package:flutter/cupertino.dart';

import '../../domain/repositories/storage_repository.dart'; // Domain Repository Interface 임포트
import '../datasources/firebase_storage_data_source.dart'; // FirebaseStorageDataSource 임포트
import 'dart:io'; // File 클래스 사용

// StorageRepository 인터페이스를 구현 (implements)
class StorageRepositoryImpl implements StorageRepository {
  // DataSource에 의존 (실제 데이터 처리 위임)
  final FirebaseStorageDataSource dataSource;

  // 생성자로 DataSource 구현체를 주입받음
  StorageRepositoryImpl(this.dataSource);

  // Domain Layer에서 정의한 uploadImage() 메서드 구현
  // Future<String> (다운로드 URL) 반환
  @override
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // DataSource에게 이미지 업로드 요청 위임
      // DataSource는 Firebase Storage에 업로드하고 URL을 반환
      final downloadUrl = await dataSource.uploadImage(imageFile, path);

      // 다운로드 URL 반환
      return downloadUrl;

    } catch (e) {
      // DataSource에서 발생한 에러를 여기서 잡거나 다시 던질 수 있음
      debugPrint('Error in StorageRepositoryImpl.uploadImage: $e');
      rethrow; // 잡은 에러를 다시 던짐
    }
  }

  // TODO: 필요에 따라 deleteImage() 메서드 구현
  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      await dataSource.deleteImage(imageUrl);
    } catch (e) {
      debugPrint('Error in StorageRepositoryImpl.deleteImage: $e');
      rethrow;
    }
  }
}
