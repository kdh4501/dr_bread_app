import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/user.dart'; // Domain Entity
import '../../domain/repositories/auth_repository.dart'; // Domain Repository Interface
import '../datasources/firebase_auth_data_source.dart'; // Data Source

/*
Domain Layer의 AuthRepository 인터페이스를 구현하고 DataSource를 사용하여 데이터 가져옴.
(여기서 Firebase User를 Domain Layer UserEntity로 변환)
 */
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource; // DataSource에 의존
  AuthRepositoryImpl(this.dataSource);

  @override
  Stream<UserEntity?> get authStateChanges {
    // Firebase User 스트림을 Domain Layer Entity 스트림으로 변환
    return dataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      // Firebase User 객체를 Domain Layer UserEntity 객체로 매핑
      return UserEntity(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
    });
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final userCredential = await dataSource.signInWithGoogle();
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return null; // 로그인 실패 또는 사용자 정보 없음
      }
      // Firebase User 객체를 Domain Layer UserEntity 객체로 매핑
      return UserEntity(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
    } catch (e) {
      // 데이터 소스 에러를 Domain Layer 또는 Presentation Layer에서 처리할 수 있도록 던지거나 변환
      debugPrint('Error in AuthRepositoryImpl.signInWithGoogle: $e');
      throw e; // 또는 커스텀 에러 타입으로 변환하여 던짐
    }
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // DataSource를 통해 Firebase Auth에서 현재 사용자 정보 가져옴
    final firebaseUser = await dataSource.authStateChanges.first; // Stream의 첫 번째 데이터 가져오기
    // 또는 FirebaseAuth.instance.currentUser 사용 (DataSource에서)

    if (firebaseUser == null) {
      return null;
    }
    final uid = firebaseUser.uid;
    // Firebase User 객체를 Domain Layer UserEntity 객체로 매핑
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }
}
