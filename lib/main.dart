import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_bread_app/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/presentation/providers/authentication_provider.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'features/recipe/data/datasources/firestore_recipe_data_source.dart';
import 'features/recipe/data/repositories/recipe_repository_impl.dart';
import 'features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'features/recipe/domain/usecases/search_recipes_usecase.dart';
import 'features/recipe/presentation/providers/recipe_list_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn(); // google_sign_in 패키지 사용

  // Data Source 및 Repository 구현체 인스턴스 생성
  final authDataSource = FirebaseAuthDataSource(firebaseAuth, googleSignIn);
  final firestoreRecipeDataSource = FirestoreRecipeDataSource(firebaseFirestore); // TODO: Firestore 인스턴스 전달 필요시 수정

  final authRepository = AuthRepositoryImpl(authDataSource);
  final recipeRepository = RecipeRepositoryImpl(firestoreRecipeDataSource);


  final signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository); // 로그아웃 UseCase

  // 레시피 관련 UseCase 인스턴스 생성 (RecipeRepository에 의존)
  final getRecipesUseCase = GetRecipesUseCase(recipeRepository);
  final searchRecipesUseCase = SearchRecipesUseCase(recipeRepository);

  runApp(
    // MultiProvider를 사용하여 여러 Provider 설정 가능
    MultiProvider(
      providers: [
        // AuthProvider 설정: UseCase 주입
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(signInWithGoogleUseCase, signOutUseCase),
          // lazy: false, // 앱 시작 시 바로 AuthProvider 생성 (선택 사항)
        ),
        ChangeNotifierProvider<RecipeListProvider>( // <-- 추가!
          create: (_) => RecipeListProvider(getRecipesUseCase, searchRecipesUseCase), // <-- UseCase 주입!
          // lazy: false, // 앱 시작 시 바로 RecipeListProvider 생성 (선택 사항)
        ),
        Provider<RecipeRepository>( // <-- 추가!
          create: (_) => recipeRepository, // <-- 위에서 생성한 RecipeRepositoryImpl 인스턴스 제공!
        ),
        // TODO: RecipeListProvider 등 레시피 관련 Provider 추가
        // ChangeNotifierProvider<RecipeListProvider>(
        //   create: (_) => RecipeListProvider(...),
        // ),
      ],
      child: const MyApp(), // 하위 위젯들이 Provider에 접근 가능
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '빵빵박사', // 앱 이름
      // TODO: 네 '빵빵박사' 앱의 색상 팔레트, 폰트 등 테마 설정
      theme: ThemeData(
        primarySwatch: Colors.pink, // 예시 색상 (따뜻한 느낌?)
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true, // Material 3 디자인 사용 여부
        fontFamily: 'YourFont', // TODO: Google Fonts 등에서 다운받은 폰트 이름
        textTheme: const TextTheme( // 텍스트 스타일 정의
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
          // ... 필요한 텍스트 스타일 정의
        ),
        appBarTheme: const AppBarTheme( // 앱바 테마 설정
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white, // 앱바 글씨/아이콘 색상
        ),
        cardTheme: CardTheme( // 카드 위젯 테마 설정 (레시피 목록 카드 등)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData( // FAB 테마
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
        ),
        // ... 기타 위젯 테마 설정
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거 (출시 시)
      // home 속성에 로그인 상태에 따라 화면을 분기하는 위젯 지정
      home: const AuthWrapper(), // AuthWrapper가 스플래시 -> 로그인/메인 전환 처리
      // TODO: 만약 별도의 스플래시 스크린을 home으로 설정한다면 Navigator 로직 필요
      // home: const SplashScreen(), // SplashScreen을 홈으로 설정 시
      // routes: { // 라우트 설정 (선택 사항, go_router 등 활용 가능)
      //   '/login': (context) => const LoginScreen(),
      //   '/main': (context) => const MainRecipeListScreen(),
      // },
    );
  }
}
