import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_bread_app/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:dr_bread_app/theme/app_theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'features/recipe/data/datasources/firebase_storage_data_source.dart';
import 'features/recipe/data/datasources/firestore_recipe_data_source.dart';
import 'features/recipe/data/datasources/firestore_review_data_source.dart';
import 'features/recipe/data/repositories/recipe_repository_impl.dart';
import 'features/recipe/data/repositories/review_repository_impl.dart';
import 'features/recipe/data/repositories/storage_repository_impl.dart';
import 'features/recipe/domain/repositories/review_repository.dart';
import 'features/recipe/domain/repositories/storage_repository.dart';
import 'features/recipe/domain/usecases/add_recipe_usecase.dart';
import 'features/recipe/domain/usecases/add_review_usecase.dart';
import 'features/recipe/domain/usecases/delete_recipe_usecase.dart';
import 'features/recipe/domain/usecases/delete_review_usecase.dart';
import 'features/recipe/domain/usecases/get_recipe_detail_usecase.dart';
import 'features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'features/recipe/domain/usecases/get_reviews_for_recipe_usecase.dart';
import 'features/recipe/domain/usecases/search_recipes_usecase.dart';
import 'features/recipe/domain/usecases/update_recipe_usecase.dart';
import 'features/recipe/domain/usecases/update_review_usecase.dart';
import 'features/recipe/domain/usecases/upload_image_usecase.dart';
import 'features/recipe/presentation/bloc/recipe_action_bloc.dart';
import 'features/recipe/presentation/bloc/recipe_detail_bloc.dart';
import 'features/recipe/presentation/bloc/recipe_list_bloc.dart';
import 'features/recipe/presentation/bloc/review_bloc.dart';
import 'features/recipe/presentation/providers/recipe_list_provider.dart';
import 'firebase_options.dart';

// get_it 인스턴스 생성
final getIt = GetIt.instance;

void main() async {
  // 스플래시 스크린 유지 시작
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      appleProvider: kReleaseMode
          ? AppleProvider.deviceCheck
          : AppleProvider.debug,
    );

    Bloc.observer = SimpleBlocObserver();

    // get_it 의존성 등록 함수
    setupDependencies();
    // 앱 초기화 완료 후 스플래시 스크린 제거
    FlutterNativeSplash.remove();
    runApp(
      // MultiProvider를 사용하여 여러 Provider 설정 가능
      MultiProvider(
        providers: [
          // AuthProvider 설정: UseCase 주입
          // ChangeNotifierProvider<AuthenticationProvider>(
          //   create: (_) => AuthenticationProvider(getIt<SignInWithGoogleUseCase>(), getIt<SignOutUseCase>()),
          //   // lazy: false, // 앱 시작 시 바로 AuthProvider 생성 (선택 사항)
          // ),
          // AuthProvider 대신 AuthBloc을 BlocProvider로 등록
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              getIt<SignInWithGoogleUseCase>(),
              getIt<SignOutUseCase>(),
              getIt<AuthRepository>(), // AuthRepository 주입
            ),
          ),
          // RecipeListProvider 대신 RecipeListBloc을 BlocProvider로 등록
          BlocProvider<RecipeListBloc>(
            create: (_) => RecipeListBloc(getIt<GetRecipesUseCase>(), getIt<SearchRecipesUseCase>()),
          ),
          BlocProvider<RecipeActionBloc>(
            create: (_) => RecipeActionBloc(
              getIt<AddRecipeUseCase>(),
              getIt<UpdateRecipeUseCase>(),
              getIt<DeleteRecipeUseCase>(),
              getIt<UploadImageUseCase>(),
              getIt<RecipeRepository>(),
            ),
          ),
          BlocProvider<RecipeDetailBloc>(
            create: (_) => RecipeDetailBloc(getIt<GetRecipeDetailUseCase>()),
          ),
          BlocProvider<ReviewBloc>(
            create: (_) => ReviewBloc(
              getIt<AddReviewUseCase>(),
              getIt<GetReviewsForRecipeUseCase>(),
              getIt<DeleteReviewUseCase>(),
              getIt<UpdateReviewUseCase>(),
            ),
          ),
        ],
        child: const MyApp(), // 하위 위젯들이 Provider에 접근 가능
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Fatal Error during app initialization: $e');
    debugPrint('StackTrace: $stackTrace');
    // 에러 발생 시 앱이 꺼지지 않고 에러 화면을 보여주도록 할 수도 있음
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('앱 초기화 중 심각한 오류 발생: $e\n자세한 내용은 로그를 확인해주세요.'),
          ),
        ),
      ),
    );
  }
}

Future<void> setupDependencies() async {
  // Firebase 인스턴스 등록 (Singleton)
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance); // FirebaseStorage 인스턴스 등록

  // Data Source 구현체 등록 (LazySingleton)
  // DataSource는 Repository가 필요할 때 생성되도록 LazySingleton으로 등록
  getIt.registerLazySingleton<AuthDataSource>(
          () => FirebaseAuthDataSource(getIt<FirebaseAuth>(), getIt<GoogleSignIn>())); // 의존성 주입
  getIt.registerLazySingleton<FirestoreRecipeDataSource>(
          () => FirestoreRecipeDataSource(getIt<FirebaseFirestore>())); // 의존성 주입
  getIt.registerLazySingleton<FirebaseStorageDataSource>( // FirebaseStorageDataSource 구현체 등록
          () => FirebaseStorageDataSource(getIt<FirebaseStorage>())); // 의존성 주입
  getIt.registerLazySingleton<UpdateReviewUseCase>(
          () => UpdateReviewUseCase(getIt<ReviewRepository>()));

  // Repository 구현체 등록 (Singleton)
  // Repository는 여러 UseCase에서 공유되므로 Singleton으로 등록
  getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(getIt<AuthDataSource>())); // 의존성 주입
  getIt.registerSingleton<RecipeRepository>(
      RecipeRepositoryImpl(getIt<FirestoreRecipeDataSource>())); // 의존성 주입
  getIt.registerSingleton<StorageRepository>( // StorageRepository 구현체 등록
      StorageRepositoryImpl(getIt<FirebaseStorageDataSource>())); // 의존성 주입

  // Domain Layer UseCase 등록 (LazySingleton)
  // UseCase는 필요할 때 생성되도록 LazySingleton으로 등록
  getIt.registerLazySingleton<SignInWithGoogleUseCase>(
          () => SignInWithGoogleUseCase(getIt<AuthRepository>())); // 의존성 주입
  getIt.registerLazySingleton<SignOutUseCase>(
          () => SignOutUseCase(getIt<AuthRepository>())); // 의존성 주입
  getIt.registerLazySingleton<GetRecipesUseCase>(
          () => GetRecipesUseCase(getIt<RecipeRepository>())); // 의존성 주입
  getIt.registerLazySingleton<SearchRecipesUseCase>(
          () => SearchRecipesUseCase(getIt<RecipeRepository>())); // 의존성 주입
  // 상세/추가/편집/삭제 UseCase 등록
  getIt.registerLazySingleton<GetRecipeDetailUseCase>(
          () => GetRecipeDetailUseCase(getIt<RecipeRepository>()));
  getIt.registerLazySingleton<AddRecipeUseCase>(
          () => AddRecipeUseCase(getIt<RecipeRepository>(), getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdateRecipeUseCase>(
          () => UpdateRecipeUseCase(getIt<RecipeRepository>()));
  getIt.registerLazySingleton<DeleteRecipeUseCase>(
          () => DeleteRecipeUseCase(getIt<RecipeRepository>(), getIt<StorageRepository>()));
  // 이미지 업로드 UseCase 등록
  getIt.registerLazySingleton<UploadImageUseCase>( // TODO: UploadImageUseCase 구현 필요
          () => UploadImageUseCase(getIt<StorageRepository>())); // 의존성 주입 // TODO: StorageRepository 인터페이스 구현 필요

  // Review 관련 DataSource, Repository, UseCase 등록
  getIt.registerLazySingleton<FirestoreReviewDataSource>(
          () => FirestoreReviewDataSource(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton<ReviewRepository>(
          () => ReviewRepositoryImpl(getIt<FirestoreReviewDataSource>()));
  getIt.registerLazySingleton<AddReviewUseCase>(
          () => AddReviewUseCase(getIt<ReviewRepository>(), getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetReviewsForRecipeUseCase>(
          () => GetReviewsForRecipeUseCase(getIt<ReviewRepository>()));
  getIt.registerLazySingleton<DeleteReviewUseCase>(
          () => DeleteReviewUseCase(getIt<ReviewRepository>()));

  // Provider는 MultiProvider에서 생성하지만, 필요한 UseCase 등은 get_it에서 가져옴
  // 예시: AuthProvider 생성자에서 getIt 사용
  // AuthProvider(getIt<SignInWithGoogleUseCase>(), getIt<SignOutUseCase>())
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('Bloc Event: ${bloc.runtimeType}, $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('Bloc Transition: ${bloc.runtimeType}, ${transition.currentState} -> ${transition.nextState}');
  }


  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('Bloc Error: ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('Bloc Change: ${bloc.runtimeType}, ${change.currentState} -> ${change.nextState}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MaterialApp(
      title: '빵빵박사', // 앱 이름
      // TODO: 네 '빵빵박사' 앱의 색상 팔레트, 폰트 등 테마 설정
      theme: bbangbaksaTheme,
      debugShowCheckedModeBanner: true, // false 시 디버그 배너 제거 (출시 시)
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
