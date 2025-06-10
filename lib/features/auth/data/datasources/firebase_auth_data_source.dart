import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart'; // Domain Layer Entity 사용

abstract class AuthDataSource {
  Stream<User?> get authStateChanges; // Firebase User 타입 반환
  Future<UserCredential> signInWithGoogle(); // Firebase UserCredential 반환
  Future<void> signOut();
}

/*
파이어베이스 SDK를 직접 사용하는 코드 (데이터 소스)
 */
class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // Firebase SDK 직접 사용

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Firebase + GoogleSignIn 로직 (이전에 봤던 코드)
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // 사용자가 로그인 취소
      throw Exception('Google Sign-In cancelled'); // 에러 처리
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential); // Firebase SDK 직접 사용
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
