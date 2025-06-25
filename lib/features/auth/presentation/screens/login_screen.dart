import 'package:dr_bread_app/core/constants/app_contstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Provider 사용 예시
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../providers/authentication_provider.dart'; // AuthProvider 주입
import '../widgets/google_sign_in_button.dart'; // Google 로그인 버튼 위젯 사용

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bloc의 상태를 직접 listen하지 않고, BlocProvider.of를 통해 Bloc 인스턴스에 접근
    // 또는 context.read<AuthBloc>() 사용
    final authBloc = context.read<AuthBloc>(); // Bloc 인스턴스 가져오기

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/bbangbaksa_logo.png', width: 100, height: 100), // 로고
              SizedBox(height: 20),
              Text(
                '빵빵박사', // 앱 이름
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '나만의 제빵/제과 레시피를 기록하고 관리하세요!', // 슬로건
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 40),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // 로딩 중이면 로딩 스피너 표시
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }
                    // 로딩 중이 아니면 Google 로그인 버튼 표시
                    return GoogleSignInButton(
                      onPressed: () {
                        // Bloc에 이벤트 추가
                        authBloc.add(AuthSignInWithGoogle()); // <-- 이벤트 추가!
                      },
                    );
                  },
                ),
              ),
              // TODO: 이메일/비밀번호 로그인 UI 추가 가능
            ],
          ),
        ),
      ),
    );
  }
}
