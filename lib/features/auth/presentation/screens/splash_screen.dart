import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
// TODO: 필요시 Future.delayed 등을 위한 dart:async 임포트

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // TODO: 스플래시 화면에서 수행할 비동기 작업 (예: Firebase 초기화 완료 대기, 초기 데이터 로딩)
  // 또는 최소 노출 시간 설정
  @override
  void initState() {
    super.initState();
    // TODO: 여기서 비동기 작업 수행 후 네비게이션 처리
    // 예시: 3초 후 AuthWrapper로 이동 (실제는 로딩 완료 후 이동)
    // Future.delayed(Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/auth_wrapper'); // 라우트 사용 시
    //   // 또는 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthWrapper())); // 위젯 직접 이동 시
    // });
    _checkAuthAndNavigate(); // 인증 상태 확인 및 이동 함수 호출
  }

  // TODO: Firebase 초기화 및 로그인 상태 확인 후 화면 이동 함수
  void _checkAuthAndNavigate() async {
    // 여기서는 AuthWrapper가 이 역할을 하므로 이 스플래시에서는 단순히 로고만 보여주고
    // AuthWrapper가 다음 화면을 결정하게 할 수도 있음.
    // 만약 이 스플래시에서 직접 로그인 상태를 체크하려면 FirebaseAuth.instance.currentUser 등을 사용
    // await Future.delayed(Duration(seconds: 2)); // 최소 로딩 시간

    // TODO: 필요시 복잡한 초기화 로직 수행

    // AuthWrapper로 이동 (AuthWrapper가 실제 로그인 상태 분기)
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthWrapper()));
    // 또는 AuthWrapper가 home에 이미 설정되어 있다면 별도의 네비게이션 필요 없을 수도 있음.
    // 이 경우 SplashScreen은 AuthWrapper의 로딩 상태일 때만 보이고,
    // initState에서 별도의 네비게이션 코드는 없을 수 있음.
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // TODO: 스플래시 스크린 UI 디자인
      body: BackgroundGradient(
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 네 앱 로고 이미지
            // Image.asset('assets/images/bbangbaksa_logo.png', width: 150, height: 150),
            // SizedBox(height: 20),
            CircularProgressIndicator(), // 로딩 표시
            SizedBox(height: 20),
            Text('앱 준비 중...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      )
    );
  }
}