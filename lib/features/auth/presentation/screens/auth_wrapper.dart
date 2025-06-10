import 'package:dr_bread_app/features/auth/presentation/providers/authentication_provider.dart';
import 'package:dr_bread_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart'; // 로그인 화면
import '../../../recipe/presentation/screens/main_recipe_list_screen.dart'; // 메인 화면
import '../../shared/screens/splash_screen.dart'; // TODO: 스플래시 스크린 임포트

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    // AuthProvider의 로딩 상태나 초기화 상태를 보고 스플래시/로딩 화면 표시 결정
    // Provider가 초기화되고 인증 상태를 확인하는 동안 로딩 상태일 수 있음
    // TODO: 실제 스플래시 스크린 로직과 연동 필요
    if (authProvider.isLoading) { // 예시 로딩 체크 (실제 스플래시 로직과 다를 수 있음)
      return const SplashScreen(); // 로딩 중이면 스플래시 스크린 보여줌
    }


    // 사용자가 로그인 되어 있으면 (currentUser != null) 메인 화면 보여줌
    if (authProvider.currentUser != null) {
      return const MainRecipeListScreen();
    } else {
      // 사용자가 로그인 되어 있지 않으면 로그인 화면 보여줌
      return const LoginScreen();
    }
  }
}