// lib/features/recipe/data/datasources/firebase_storage_data_source.dart
// Data Layer DataSource: 파이어베이스 Storage와 직접 통신

import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage SDK 사용
import 'dart:io';

import 'package:flutter/cupertino.dart'; // File 클래스 사용

// Firebase Storage 데이터 소스 구현체
class FirebaseStorageDataSource {

  // FirebaseStorage 인스턴스에 의존 (main.dart에서 get_it으로 주입받음)
  final FirebaseStorage _storage;

  // 생성자로 FirebaseStorage 인스턴스를 주입받음
  FirebaseStorageDataSource(this._storage);

  // 이미지 파일을 Firebase Storage에 업로드하고 다운로드 URL을 반환하는 메서드
  // Future<String> 반환
  // File imageFile: 업로드할 이미지 파일 객체
  // String path: Storage에 저장될 경로 (예: 'recipe_images/...')
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Storage 참조 생성 (저장될 경로 지정)
      final ref = _storage.ref().child(path);

      // 파일 업로드
      final uploadTask = ref.putFile(imageFile);

      // 업로드 완료까지 대기 및 결과 확인
      final snapshot = await uploadTask.whenComplete(() => null); // 업로드 완료 대기

      // 업로드된 파일의 다운로드 URL 가져오기
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 다운로드 URL 반환
      return downloadUrl;

    } on FirebaseException catch (e) {
      // Firebase Storage 관련 에러 처리
      debugPrint('Firebase Storage upload error: ${e.code} - ${e.message}');
      // 에러를 다시 던져서 Repository나 UseCase에서 처리하도록 함
      rethrow;
    } catch (e) {
      // 기타 에러 처리
      debugPrint('Storage upload error: $e');
      rethrow;
    }
  }

  // TODO: 필요에 따라 이미지 삭제 등 추가적인 메서드 구현
  Future<void> deleteImage(String imageUrl) async {
    try {
      // URL로부터 Storage 참조 가져오기
      final ref = _storage.refFromURL(imageUrl);
      // 파일 삭제
      await ref.delete();
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage delete error: ${e.code} - ${e.message}');
      rethrow; // 에러 다시 던짐
    } catch (e) {
      debugPrint('Firebase Storage delete error: $e');
      rethrow;
    }
  }
}
