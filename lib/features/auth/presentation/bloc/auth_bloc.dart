// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase User UID 가져오기용 (getIt으로 가져옴)
import 'package:get_it/get_it.dart'; // getIt 사용

import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/auth_repository.dart'; // authStateChanges 스트림 구독용

import 'auth_event.dart';
import 'auth_state.dart';

final getIt = GetIt.instance; // getIt 인스턴스 가져오기

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository; // 인증 상태 스트림 구독용

  // StreamSubscription<UserEntity?>? _authStateSubscription; // 스트림 구독 관리 (선택 사항)

  AuthBloc(this._signInWithGoogleUseCase, this._signOutUseCase, this._authRepository) : super(AuthInitial()) {
    // 각 이벤트에 대한 핸들러 등록
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInWithGoogle>(_onAuthSignInWithGoogle);
    on<AuthSignOut>(_onAuthSignOut);

    // 앱 시작 시 인증 상태 변화 스트림 구독 (Bloc 생성 시)
    // _authRepository.authStateChanges 스트림을 listen하여 상태 변화 시 AuthStarted 이벤트를 추가
    // 또는 직접 상태를 emit
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user)); // 인증된 사용자면 AuthAuthenticated 상태 발행
      } else {
        emit(AuthUnauthenticated()); // 인증되지 않은 사용자면 AuthUnauthenticated 상태 발행
      }
    });
  }

  // AuthStarted 이벤트 핸들러
  Future<void> _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // 앱 시작 시 초기 인증 상태 확인 로직 (이미 스트림에서 처리되므로 여기서는 간단히)
    // emit(AuthLoading()); // 필요시 로딩 상태 발행
    // try {
    //   final user = await _authRepository.getCurrentUser(); // 현재 사용자 정보 가져오기
    //   if (user != null) {
    //     emit(AuthAuthenticated(user));
    //   } else {
    //     emit(AuthUnauthenticated());
    //   }
    // } catch (e) {
    //   emit(AuthError('인증 상태 확인 실패: $e'));
    // }
  }

  // AuthSignInWithGoogle 이벤트 핸들러
  Future<void> _onAuthSignInWithGoogle(AuthSignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // 로딩 상태 발행
    try {
      final user = await _signInWithGoogleUseCase(); // UseCase 실행
      if (user != null) {
        emit(AuthAuthenticated(user)); // 인증 성공 상태 발행
      } else {
        emit(AuthError('Google 로그인 실패: 사용자 정보 없음')); // 사용자 정보 없으면 에러
      }
    } catch (e) {
      emit(AuthError('Google 로그인 실패: ${e.toString()}')); // 에러 상태 발행
    }
  }

  // AuthSignOut 이벤트 핸들러
  Future<void> _onAuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // 로딩 상태 발행
    try {
      await _signOutUseCase(); // UseCase 실행
      emit(AuthUnauthenticated()); // 로그아웃 상태 발행
    } catch (e) {
      emit(AuthError('로그아웃 실패: ${e.toString()}')); // 에러 상태 발행
    }
  }

// Bloc이 dispose될 때 스트림 구독 취소 (선택 사항, Bloc이 자동으로 관리하기도 함)
// @override
// Future<void> close() {
//   _authStateSubscription?.cancel();
//   return super.close();
// }
}
