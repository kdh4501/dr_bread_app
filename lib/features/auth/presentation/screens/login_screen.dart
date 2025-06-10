import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용 예시
import '../providers/authentication_provider.dart'; // AuthProvider 주입
import '../widgets/google_sign_in_button.dart'; // Google 로그인 버튼 위젯 사용

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider 상태 변화를 listen
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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

              // 로딩 중이면 로딩 인디케이터 표시
              if (authenticationProvider.isLoading)
                CircularProgressIndicator()
              else
                // Google 로그인 버튼 위젯 사용
                GoogleSignInButton(
                  onPressed: () {
                    authenticationProvider.signInWithGoogle(); // Provider의 로그인 함수 호출
                  },
                ),

              // TODO: 이메일/비밀번호 로그인 UI 추가 가능
            ],
          ),
        ),
      ),
    );
  }
}
