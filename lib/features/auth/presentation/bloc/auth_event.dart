
// AuthBloc이 처리할 이벤트들을 정의
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {} // 앱 시작 시 인증 상태 확인 이벤트

class AuthSignInWithGoogle extends AuthEvent {} // Google 로그인 이벤트

class AuthSignOut extends AuthEvent {} // 로그아웃 이벤트