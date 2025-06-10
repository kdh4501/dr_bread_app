import 'package:dr_bread_app/features/auth/domain/entities/user.dart';

/*
인증 관련 동작을 정의한 인터페이스 (어떻게 구현될지는 Domain Layer는 모름)
 */
abstract class AuthRepository {
  // Google 로그인 후 사용자 정보를 스트림으로 제공
  Stream<UserEntity?> get authStateChanges;

  // Google 로그인 실행
  Future<UserEntity?> signInWithGoogle();

  // 로그아웃 실행
  Future<void> signOut();

  // TODO: 이메일/비밀번호 등 다른 인증 메서드 정의
}