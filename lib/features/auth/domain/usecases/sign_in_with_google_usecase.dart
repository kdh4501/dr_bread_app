import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/*
구글 로그인 비즈니스 로직 (단순 호출일 수 있지만, 더 복잡한 로직이 들어갈 수도 있음)
 */
class SignInWithGoogleUseCase {
  final AuthRepository repository; // 인터페이스에 의존

  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> call() async { // UseCase는 보통 call() 메서드 사용
    return await repository.signInWithGoogle();
  }
}