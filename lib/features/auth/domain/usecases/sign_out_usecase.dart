import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository; // 인터페이스에 의존

  SignOutUseCase(this.repository);

  Future<void> call() async { // UseCase는 보통 call() 메서드 사용
    return await repository.signOut();
  }
}