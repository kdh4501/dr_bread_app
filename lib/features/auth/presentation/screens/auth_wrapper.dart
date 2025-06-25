import 'package:dr_bread_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dr_bread_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:dr_bread_app/features/auth/presentation/providers/authentication_provider.dart';
import 'package:dr_bread_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/auth_event.dart';
import 'login_screen.dart'; // 로그인 화면
import '../../../recipe/presentation/screens/main_recipe_list_screen.dart'; // TODO: 스플래시 스크린 임포트

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder를 사용하여 AuthBloc의 상태 변화를 구독
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const SplashScreen();
        }  else if (state is AuthAuthenticated) {
          // 인증 성공 상태
          return const MainRecipeListScreen();
        } else if (state is AuthUnauthenticated) {
          // 인증되지 않은 상태 (로그인 화면)
          return const LoginScreen();
        } else if (state is AuthError) {
          // 에러 상태 (에러 메시지 표시)
          // TODO: 에러 메시지를 사용자에게 보여주는 UI 추가
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류 발생: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      // 에러 발생 시 다시 로그인 화면으로 이동하거나 재시도 이벤트 추가
                      context.read<AuthBloc>().add(AuthStarted()); // 다시 시작 이벤트
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }
        // 초기 상태 또는 알 수 없는 상태 (기본값)
        return const SplashScreen();
      },
    );
  }
}