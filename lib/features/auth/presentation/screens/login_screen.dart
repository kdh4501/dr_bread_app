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
    final authBloc = context.read<AuthBloc>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Bloc의 상태를 직접 listen하지 않고, BlocProvider.of를 통해 Bloc 인스턴스에 접근
    // 또는 context.read<AuthBloc>() 사용

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/bbangbaksa_logo.png', width: 120, height: 120), // 로고
              SizedBox(height: kSpacingMedium),
              Text(
                kAppName, // app_constants.dart에서 앱 이름 가져오기
                style: textTheme.headlineLarge?.copyWith(color: colorScheme.primary), // 앱 이름 강조
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                '나만의 제빵/제과 레시피를 기록하고 관리하세요!', // 슬로건
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground),
              ),
              SizedBox(height: kSpacingLarge),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: colorScheme.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return CircularProgressIndicator(color: colorScheme.primary);
                  }
                  return ElevatedButton(
                    onPressed: () {
                      authBloc.add(AuthSignInWithGoogle());
                    },
                    child: Text('Google 계정으로 시작하기', style: textTheme.labelLarge), // labelLarge 스타일
                    style: ElevatedButton.styleFrom( // ElevatedButtonThemeData 자동 적용
                      minimumSize: const Size(double.infinity, 50), // 버튼 최소 크기
                    ),
                  );
                },
              )
              // TODO: 이메일/비밀번호 로그인 UI 추가 가능
            ],
          ),
        ),
      ),
    );
  }
}
