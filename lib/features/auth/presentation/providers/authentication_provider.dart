import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ↓↓↓↓↓ Stream 구독을 관리할 변수 선언 (인증 상태 스트림) ↓↓↓↓↓
  StreamSubscription<UserEntity?>? _authStateSubscription; // <-- AuthProvider에서 관리할 스트림 구독 변수

  // ↓↓↓↓↓ 생성자로 UseCase 인스턴스를 주입받음 ↓↓↓↓↓
  AuthenticationProvider(this._signInWithGoogleUseCase, this._signOutUseCase) {
    // 앱 시작 시 인증 상태 변화 스트림 구독 (AuthRepositoryImpl의 authStateChanges 사용)
    // UseCase의 Repository에 접근하여 스트림을 가져옴
    _authStateSubscription = _signInWithGoogleUseCase.repository.authStateChanges.listen(
          (user) { // 스트림에서 새로운 UserEntity 또는 null이 발행될 때마다 이 블록 실행
        _currentUser = user; // 스트림에서 받은 UserEntity (또는 null)로 상태 업데이트
        // TODO: 여기서 필요시 로딩 상태 업데이트나 초기화 로직 처리 (예: 앱 시작 시 초기 인증 상태 확인 중 로딩 표시)
        // _isLoading = false; // 초기 인증 상태 확인 완료 시 로딩 종료 (옵션)
        _errorMessage = null; // 인증 상태 변경 시 에러 초기화 (옵션)
        notifyListeners(); // 상태 변경 알림
      },
      onError: (error) { // 스트림에서 에러 발생 시
        _errorMessage = '인증 상태 확인 중 오류 발생: $error'; // 에러 메시지
        _currentUser = null; // 에러 발생 시 사용자 정보 비움
        // _isLoading = false; // 로딩 종료
        notifyListeners();
        debugPrint('인증 상태 스트림 에러 발생: $error');
      },
      onDone: () {
        // _isLoading = false;
        notifyListeners();
        debugPrint('인증 상태 스트림 종료');
      },
      cancelOnError: true,
    );
    debugPrint('AuthProvider initialized and authStateChanges stream subscribed.');
  }

  // Google 로그인 실행
  Future<void> signInWithGoogle() async {
    debugPrint('AuthenticationProvider signInWithGoogle called!');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // 로딩 시작 알림

    try {
      final user = await _signInWithGoogleUseCase.call(); // UseCase 실행

      _currentUser = user; // UseCase 실행 결과(UserEntity)로 상태 업데이트
      _errorMessage = null; // 성공 시 에러 없음
    } catch (e) {
      // UseCase 실행 중 발생한 에러 처리
      debugPrint('Error during Google Sign-In or Firebase Auth: $e');
      _errorMessage = '로그인 중 오류 발생: ${e.toString()}';
      _currentUser = null; // 에러 발생 시 사용자 정보 초기화
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 종료 및 상태 변경 알림
    }
  }

  // 로그아웃 실행
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null; // 로그아웃 시도 시 이전 에러 메시지 초기화
    notifyListeners();

    try {
      await _signOutUseCase.call(); // 로그아웃 UseCase 실행

      _currentUser = null; // 상태 업데이트
      _errorMessage = null; // 성공 시 에러 없음
    } catch (e) {
      // TODO: 에러 처리
      debugPrint('로그아웃 실패: $e');
      _errorMessage = '로그아웃 실패: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Provider가 더 이상 필요 없어질 때 호출되어 자원 정리
  @override
  void dispose() {
    debugPrint('AuthProvider disposed. Cancelling authStateSubscription.');
    _authStateSubscription?.cancel(); // 인증 상태 스트림 구독 취소
    // TODO: 다른 StreamSubscription이나 컨트롤러 등 해제

    super.dispose();
  }
}
