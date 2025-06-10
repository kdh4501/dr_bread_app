import 'package:flutter/material.dart';
// 필요하다면 Font Awesome 아이콘을 위한 패키지 임포트
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleSignInButton extends StatelessWidget {
  // 버튼이 눌렸을 때 실행될 함수를 외부에서 받기 위한 final 변수
  final VoidCallback onPressed;

  // 생성자: onPressed 함수를 필수로 받도록 정의
  const GoogleSignInButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material Design의 ElevatedButton을 사용하여 버튼 UI 구현
    return ElevatedButton.icon(
      // onPressed 속성에 외부에서 전달받은 함수 연결
      onPressed: onPressed,

      // 버튼 왼쪽에 표시될 아이콘
      icon: Image.asset(
        'assets/images/google_logo.png', // TODO: 네 프로젝트의 실제 구글 로고 이미지 경로로 변경
        height: 24.0, // 아이콘 크기
        // TODO: 아이콘 색상 등 필요한 스타일 조정
      ),
      // 만약 Font Awesome 패키지를 사용한다면 이렇게 쓸 수도 있음:
      // icon: Icon(FontAwesomeIcons.google, color: Colors.blue),

      // 버튼 오른쪽에 표시될 텍스트
      label: Text(
        'Google 계정으로 시작하기', // 버튼 텍스트
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54, // 텍스트 색상 (약간 회색으로)
          // TODO: 네 앱의 기본 폰트 스타일 적용
        ),
      ),

      // 버튼 전체 스타일 설정
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // 배경색 흰색
        foregroundColor: Colors.black87, // 텍스트/아이콘 색상 (기본값, 위 label color가 우선)
        minimumSize: Size(double.infinity, 50), // 버튼 최소 크기 (가로 꽉 차게, 세로 50)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
          side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 (옅은 회색)
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0), // 내부 패딩
        elevation: 1.0, // 그림자 깊이
      ),
    );
  }
}
