import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart'; // 로그아웃 UseCase (별도 구현)

/*
인증 상태를 관리하고 UI에 알리는 Provider (Domain Layer UseCase 사용)
 */
class AuthenticationProvider extends ChangeNotifier { // 또는 Riverpod의 StateNotifier 등
  late final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  late final SignOutUseCase _signOutUseCase; // 로그아웃 UseCase 주입

  UserEntity? _currentUser; // 현재 로그인된 사용자 정보
  bool _isLoading = false; // 로딩 상태

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthenticationProvider(this._signInWithGoogleUseCase, this._signOutUseCase) {
    // 앱 시작 시 인증 상태 변화 스트림 구독 (AuthRepositoryImpl의 authStateChanges 사용)
    // TODO: StreamSubscription 관리 및 dispose 필요
    // 예시:
    // _signInWithGoogleUseCase.repository.authStateChanges.listen((user) {
    //   _currentUser = user;
    //   notifyListeners(); // 상태 변경 알림
    // });
  }

  // Google 로그인 실행
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners(); // 로딩 시작 알림

    try {
      final user = await _signInWithGoogleUseCase.call(); // UseCase 실행
      _currentUser = user; // 상태 업데이트
      // TODO: 로그인 성공 후 추가 로직 (예: 사용자 정보 DB 저장/업데이트)
    } catch (e) {
      // TODO: 에러 처리 (UI에 에러 메시지 표시 등)
      print('Google 로그인 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 종료 및 상태 변경 알림
    }
  }

  // 로그아웃 실행
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _signOutUseCase.call(); // 로그아웃 UseCase 실행
      _currentUser = null; // 상태 업데이트
    } catch (e) {
      // TODO: 에러 처리
      print('로그아웃 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// TODO: dispose 메서드에서 StreamSubscription 취소 등 정리 작업 수행
}
