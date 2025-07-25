import 'dart:async';

import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/add_recipe_usecase.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/get_recipe_detail_usecase.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/update_recipe_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/fab_transition_route.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../domain/usecases/delete_recipe_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../bloc/recipe_action_bloc.dart';
import '../bloc/recipe_detail_bloc.dart';
import '../bloc/recipe_list_bloc.dart';
import '../bloc/recipe_list_event.dart';
import '../bloc/recipe_list_state.dart';
import '../providers/recipe_list_provider.dart'; // RecipeListProvider 임포트
import '../widgets/empty_error_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/recipe_card.dart'; // RecipeCard 위젯 임포트
import 'add_recipe_screen.dart'; // 레시피 추가 화면 임포트
import 'recipe_detail_screen.dart'; // 레시피 상세 화면 임포트

final getIt = GetIt.instance;
class MainRecipeListScreen extends StatefulWidget { // StatefulWidget 또는 StatelessWidget 사용 가능
  const MainRecipeListScreen({super.key});

  @override
  _MainRecipeListScreenState createState() => _MainRecipeListScreenState();
}

class _MainRecipeListScreenState extends State<MainRecipeListScreen> {
  final GlobalKey _fabKey = GlobalKey();

  // 검색 바 컨트롤러
  final TextEditingController _searchController = TextEditingController();
  // 검색 바 표시 여부 (트렌디함을 반영하여 앱바에 통합)
  bool _isSearching = false;

  late final RecipeListBloc _recipeListBloc; // RecipeListBloc 인스턴스
  late final RecipeActionBloc _recipeActionBloc; // AddRecipeScreen으로 전달용
  late final AuthBloc _authBloc;

  Timer? _debounce;

  // 화면 처음 로딩 시 레시피 데이터 가져오기 호출
  @override
  void initState() {
    super.initState();
    _recipeListBloc = context.read<RecipeListBloc>();
    _recipeActionBloc = context.read<RecipeActionBloc>(); // AddRecipeScreen으로 전달용
    _authBloc = context.read<AuthBloc>();

    // 검색어 입력 변경 감지
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    // 사용자에게 로그아웃 확인 다이얼로그 띄우기
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'), // DialogTheme 자동 적용
        content: const Text('정말로 로그아웃 하시겠습니까?'),
        actions: [
          TextButton( // TextButtonTheme 자동 적용
            onPressed: () => Navigator.of(context).pop(false), // 취소
            child: const Text('취소'),
          ),
          TextButton( // TextButtonTheme 자동 적용
            onPressed: () => Navigator.of(context).pop(true), // 확인
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) { // 사용자가 확인을 눌렀을 때
      _authBloc.add(AuthSignOut()); // AuthBloc에 로그아웃 이벤트 추가
    }
  }

  // 검색어 변경 시 호출될 함수
  void _onSearchChanged() {
    // 검색어 입력 시 일정 시간 지연 후 검색 이벤트 추가 (debounce)
    if (_debounce?.isActive ?? false) _debounce!.cancel(); // 이전 타이머가 있다면 취소

    _debounce = Timer(const Duration(milliseconds: 500), () { // 500ms(0.5초) 지연 후 검색 실행
      // 타이머가 만료되면 실제 검색 이벤트 추가
      _recipeListBloc.add(SearchRecipes(_searchController.text));
    });
  }

  // 필터링 다이얼로그 표시
  void _showFilterDialog(RecipeFilterOptions currentFilter) {
    showModalBottomSheet( // 트렌디함을 반영하여 BottomSheet 사용
      context: context,
      isScrollControlled: true, // BottomSheet가 화면 전체를 차지할 수 있도록
      builder: (context) {
        return FilterBottomSheet(
          currentFilter: currentFilter,
          onApplyFilter: (newFilter) {
            _recipeListBloc.add(ApplyFilter(newFilter));
            Navigator.pop(context); // BottomSheet 닫기
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: _isSearching // 검색 중이면 검색 바, 아니면 제목
          ? TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '레시피 검색...',
              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.7)),
              border: OutlineInputBorder( // 둥근 모서리 테두리
                borderRadius: BorderRadius.circular(25.0), // 충분히 둥글게
                borderSide: BorderSide.none, // 테두리 선은 없음
              ),
              enabledBorder: OutlineInputBorder( // 활성화 시 테두리
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder( // 포커스 시 테두리
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true, // 배경색 채우기 활성화
              fillColor: colorScheme.onPrimary.withOpacity(0.15),
              prefixIcon: Icon(Icons.search, color: colorScheme.onPrimary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: colorScheme.onPrimary),
                    onPressed: () {
                      _searchController.clear();
                      _recipeListBloc.add(SearchRecipes('')); // 검색어 지우고 전체 목록 요청
                },
              )
            : null,
          ),
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
          autofocus: true, // 자동으로 포커스
        )
            :  Text('빵빵박사 레시피', style: theme.appBarTheme.titleTextStyle), // 앱바 제목
        actions: [
          // 검색 아이콘 버튼
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) { // 검색 종료 시 검색어 지우고 전체 목록 요청
                  _searchController.clear();
                  _recipeListBloc.add(SearchRecipes(''));
                }
              });
            },
          ),
          // 필터 아이콘은 검색 중이 아닐 때만 표시
          if (!_isSearching)
            BlocBuilder<RecipeListBloc, RecipeListState>( // 필터 옵션을 가져오기 위해 BlocBuilder 사용
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(state.filterOptions), // 현재 필터 옵션 전달
                );
              },
            ),
          // 프로필 아이콘 버튼 추가
          IconButton(
            icon: const Icon(Icons.person), // 프로필 아이콘
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
                        end: Offset.zero, // 왼쪽으로 이동
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300), // 전환 지속 시간
                ),
              );
            },
          ),
        ],
      ),
      body: BackgroundGradient(
        child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<RecipeListBloc, RecipeListState>(
          listener: (context, state) {
            if (state is RecipeListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? '오류가 발생했습니다.'),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            // 로딩 중 상태 처리
            if (state is RecipeListLoading) {
              return const CustomLoadingIndicator(); // 로딩 스피너
            }

            // 에러 상태 처리
            if (state is RecipeListError) {
              return EmptyErrorStateWidget( // <-- 적용!
                message: state.errorMessage ?? '레시피를 불러오는데 실패했습니다.',
                lottieAsset: 'assets/lottie/error_sad.json',
                buttonText: '다시 시도',
                onButtonPressed: () {
                  context.read<RecipeListBloc>().add(FetchRecipes());
                },
                isError: true,
              );
            }

            // 데이터 없음 상태 처리
            if (state.recipes.isEmpty) {
              // 검색어가 있는 상태에서 결과가 없으면 '검색 결과 없음' 메시지
              if (state.searchQuery.isNotEmpty || state.filterOptions != const RecipeFilterOptions()) {
                return EmptyErrorStateWidget( // <-- 적용!
                  message: '검색 결과가 없거나 필터에 해당하는 레시피가 없습니다.',
                  lottieAsset: 'assets/lottie/empty_search.json',
                  buttonText: (state.filterOptions != const RecipeFilterOptions()) ? '필터 초기화' : null,
                  onButtonPressed: (state.filterOptions != const RecipeFilterOptions())
                      ? () {
                    context.read<RecipeListBloc>().add(ApplyFilter(const RecipeFilterOptions()));
                  }
                      : null,
                );
              } else {
                // 검색어도 필터도 없는 상태에서 레시피가 없으면 '아직 레시피 없음' 메시지
                return EmptyErrorStateWidget( // <-- 적용!
                  message: '아직 레시피가 없어요!\n아래 + 버튼을 눌러 첫 레시피를 추가해보세요!',
                  lottieAsset: 'assets/lottie/empty_recipe.json',
                  // buttonText: '레시피 추가', // + 버튼이 있으므로 필요 없을 수 있음
                  // onButtonPressed: () { /* FAB와 연결 */ },
                );
              }
            }

            // 레시피 목록이 비어있으면 (검색/필터링 결과 없음 포함)
            if (state.recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: kSpacingMedium),
                    Text(
                      '검색 결과가 없거나 레시피가 없습니다.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    // 필터가 적용된 상태라면 필터 초기화 버튼
                    if (state.filterOptions != const RecipeFilterOptions())
                      TextButton(
                        onPressed: () {
                          _recipeListBloc.add(ApplyFilter(const RecipeFilterOptions())); // 필터 초기화 이벤트
                        },
                        child: const Text('필터 초기화'),
                      ),
                  ],
                ),
              );
            }

            // 레시피 목록 표시
            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding), // 상수 사용
                itemCount: state.recipes.length, // 레시피 개수
                itemBuilder: (context, index) {
                  final recipe = state.recipes[index]; // 해당 인덱스의 레시피 데이터
                  return AnimationConfiguration.staggeredList(  // 각 항목에 애니메이션 설정
                    position: index,
                    duration: const Duration(milliseconds: 375), // 각 항목 애니메이션 지속 시간
                    child: SlideAnimation(
                      verticalOffset: 50.0, // 시작 위치 (아래로 50px)
                      child: FadeInAnimation(
                        child:RecipeCard( // 레시피 카드 위젯 사용
                          recipe: recipe, // RecipeEntity 객체 전달
                          onTap: () {
                            // 레시피 카드 클릭 시 상세 화면으로 이동
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => BlocProvider<RecipeDetailBloc>(
                                  create: (context) => RecipeDetailBloc(getIt<GetRecipeDetailUseCase>()),
                                  child: RecipeDetailScreen(recipeId: recipe.uid),
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  // 좌우 슬라이드 애니메이션 적용
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0), // 오른쪽에서 시작 (화면의 오른쪽 끝)
                                      end: Offset.zero, // 왼쪽으로 이동 (화면 중앙)
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300), // 전환 지속 시간
                              ),
                            ).then((result) {
                              if (result == true) {
                                _recipeListBloc.add(FetchRecipes());
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );

          },
        ),
      ),
      ),
      // 새 레시피 추가 FAB
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          // FAB의 위치와 크기 측정
          final RenderBox fabRenderBox = _fabKey.currentContext?.findRenderObject() as RenderBox;
          final Offset fabOrigin = fabRenderBox.localToGlobal(Offset.zero);
          final Size fabSize = fabRenderBox.size;

          // 새 레시피 추가 화면으로 이동
          Navigator.push(
            context,
            // PageRouteBuilder(
            //   pageBuilder: (context, animation, secondaryAnimation) => BlocProvider<RecipeActionBloc>.value(
            //     value: _recipeActionBloc,
            //     child: const AddRecipeScreen(),
            //   ),
            //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //     // 좌우 슬라이드 애니메이션 적용
            //     return SlideTransition(
            //       position: Tween<Offset>(
            //         begin: const Offset(1.0, 0.0), // 오른쪽에서 시작 (화면의 오른쪽 끝)
            //         end: Offset.zero, // 왼쪽으로 이동 (화면 중앙)
            //       ).animate(animation),
            //       child: child,
            //     );
            //   },
            //   transitionDuration: const Duration(milliseconds: 300), // 전환 지속 시간
            // ),
            FabTransitionRoute(
              builder: (context) => BlocProvider<RecipeActionBloc>.value(
                value: _recipeActionBloc,
                child: const AddRecipeScreen(),
              ),
              fabOrigin: fabOrigin, // FAB의 시작 위치
              fabSize: fabSize, // FAB의 크기
            ),
          ).then((result) {
            if (result == true) { // 추가/편집 후 돌아왔을 때 목록 새로고침
              _recipeListBloc.add(FetchRecipes());
            }
          });
        },
        tooltip: '새 레시피 추가', // 길게 눌렀을 때 나오는 설명
        child: const Icon(Icons.add), // + 아이콘
      ),
    );
  }
}
