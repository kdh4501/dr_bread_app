import 'package:dr_bread_app/features/recipe/domain/usecases/add_recipe_usecase.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/get_recipe_detail_usecase.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/update_recipe_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../domain/usecases/upload_image_usecase.dart';
import '../providers/recipe_list_provider.dart'; // RecipeListProvider 임포트
import '../widgets/recipe_card.dart'; // RecipeCard 위젯 임포트
import 'add_recipe_screen.dart'; // 레시피 추가 화면 임포트
import 'recipe_detail_screen.dart'; // 레시피 상세 화면 임포트

class MainRecipeListScreen extends StatefulWidget { // StatefulWidget 또는 StatelessWidget 사용 가능
  const MainRecipeListScreen({super.key});

  @override
  _MainRecipeListScreenState createState() => _MainRecipeListScreenState();
}

class _MainRecipeListScreenState extends State<MainRecipeListScreen> {

  // 화면 처음 로딩 시 레시피 데이터 가져오기 호출
  @override
  void initState() {
    super.initState();
    // Provider 인스턴스에 접근하여 데이터 로딩 함수 호출
    // initState에서는 context.read<Provider>() 또는 Future.microtask 사용
    Future.microtask(() => Provider.of<RecipeListProvider>(context, listen: false).fetchRecipes());
  }


  @override
  Widget build(BuildContext context) {
    // RecipeListProvider 상태 변화를 listen (Provider 사용 예시)
    // Consumer 위젯을 사용하면 특정 부분만 리빌드하여 성능에 더 유리할 수 있음
    // 여기서는 전체 화면을 리빌드하는 Provider.of 사용
    final recipeListProvider = Provider.of<RecipeListProvider>(context);
    final getIt = GetIt.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('빵빵박사 레시피'), // 앱바 제목
        actions: [
          // 검색 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능 구현 (검색 바 노출 또는 검색 화면 이동)
              // 검색 바를 앱바 아래에 토글하거나, Navigator.push 등으로 검색 전용 화면으로 이동
              print('검색 아이콘 클릭');
            },
          ),
          // 필터 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 필터링 기능 구현 (다이얼로그 또는 화면 노출)
              print('필터 아이콘 클릭');
            },
          ),
          // TODO: 로그아웃 버튼 (옵션)
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     Provider.of<AuthProvider>(context, listen: false).signOut();
          //   },
          // ),
        ],
      ),
      body: Builder( // Builder 위젯을 사용하여 context 문제 해결 (옵션)
        builder: (context) {
          // 로딩 중 상태 처리
          if (recipeListProvider.isLoading) {
            return const Center(child: CircularProgressIndicator()); // 로딩 스피너
          }

          // 에러 상태 처리
          if (recipeListProvider.errorMessage != null) {
            return Center(child: Text('레시피 로딩 실패: ${recipeListProvider.errorMessage}')); // 에러 메시지
          }

          // 데이터 없음 상태 처리
          if (recipeListProvider.recipes.isEmpty) {
            return const Center(child: Text('아직 레시피가 없어요!\n아래 + 버튼을 눌러 첫 레시피를 추가해보세요!', textAlign: TextAlign.center,)); // 빈 화면 메시지
          }

          // 레시피 목록 표시
          return ListView.builder(
            itemCount: recipeListProvider.recipes.length, // 레시피 개수
            itemBuilder: (context, index) {
              final recipe = recipeListProvider.recipes[index]; // 해당 인덱스의 레시피 데이터
              return RecipeCard( // 레시피 카드 위젯 사용
                recipe: recipe, // RecipeEntity 객체 전달
                onTap: () {
                  // 레시피 카드 클릭 시 상세 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipeId: recipe.uid), // 상세 화면으로 이동 시 레시피 ID 전달
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // 새 레시피 추가 FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 레시피 추가 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  // ↓↓↓↓↓ get_it에서 UseCase 인스턴스를 가져와서 Provider에 전달 ↓↓↓↓↓
                  // RecipeRepository는 이제 get_it에 등록되어 있으므로 Provider로 가져올 필요 없음
                  // final recipeRepository = context.read<RecipeRepository>(); // <-- 이 코드 삭제!

                  // AddRecipeScreen에서 필요한 UseCase 인스턴스들을 get_it에서 직접 가져옴
                  final addRecipeUseCase = getIt<AddRecipeUseCase>();
                  final updateRecipeUseCase = getIt<UpdateRecipeUseCase>();
                  final getRecipeDetailUseCase = getIt<GetRecipeDetailUseCase>();
                  final uploadImageUseCase = getIt<UploadImageUseCase>(); // <-- 이미지 업로드 UseCase 가져옴

                  // final recipeRepository = Provider.of<RecipeRepository>(context, listen: false);  // 주석 풀면 오류남.
                  return MultiProvider(
                      providers: [
                        Provider<AddRecipeUseCase>(create: (_) => addRecipeUseCase,),
                        Provider<UpdateRecipeUseCase>(create: (_) => updateRecipeUseCase,),
                        Provider<GetRecipeDetailUseCase>(create: (_) => getRecipeDetailUseCase,),
                        Provider<UploadImageUseCase>(create: (_) => uploadImageUseCase),
                      ],
                    child: const AddRecipeScreen(),
                  );
                }
            ),
          );
        },
        tooltip: '새 레시피 추가', // 길게 눌렀을 때 나오는 설명
        child: const Icon(Icons.add), // + 아이콘
      ),
    );
  }
}
