
import 'package:dr_bread_app/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

// AuthBloc이 관리할 상태들을 정의
abstract class AuthState extends Equatable {
  const AuthState();  // 모든 상태는 const 생성자를 가짐

  @override
  List<Object?> get props => []; // Equatable을 위한 속성 정의
}

class AuthInitial extends AuthState {}  // 초기 상태

class AuthLoading extends AuthState {}  // 로딩 중 상태

class AuthAuthenticated extends AuthState { // 인증 성공 상태
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}  // 인증실패/로그아웃 상태

class AuthError extends AuthState { // 에러 상태
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

