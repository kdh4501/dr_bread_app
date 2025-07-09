import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
// TODO: 상세 레시피 조회 UseCase 임포트
import '../../domain/usecases/add_recipe_usecase.dart';
import '../../domain/usecases/get_recipe_detail_usecase.dart'; // UseCase
// TODO: 레시피 삭제 UseCase 임포트
import '../../domain/usecases/delete_recipe_usecase.dart'; // UseCase
// TODO: 레시피 편집 화면 임포트
import '../../domain/usecases/update_recipe_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import '../bloc/recipe_action_bloc.dart';
import '../bloc/recipe_action_event.dart';
import '../bloc/recipe_action_state.dart';
import '../bloc/recipe_detail_bloc.dart';
import '../bloc/recipe_detail_event.dart';
import '../widgets/empty_error_state_widget.dart';
import 'add_recipe_screen.dart'; // AddRecipeScreen
// TODO: 이미지 캐싱 패키지 임포트 (RecipeCard와 동일)
import 'package:cached_network_image/cached_network_image.dart';

/*
레시피 상세 정보
 */
class RecipeDetailScreen extends StatefulWidget {
  // 이전 화면에서 레시피 ID를 전달받기 위한 final 변수
  final String recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Bloc 인스턴스 가져오기
  late final RecipeActionBloc _recipeActionBloc;  // RecipeActionBloc: 레시피 추가/편집/삭제 작업의 로딩, 성공, 실패 상태를 관리.
  late final RecipeDetailBloc _recipeDetailBloc;

  @override
  void initState() {
    super.initState();
    // Bloc 인스턴스 가져오기
    _recipeActionBloc = context.read<RecipeActionBloc>();
    _recipeDetailBloc = context.read<RecipeDetailBloc>();

    // 화면 로딩 시 상세 데이터 가져오기
    // _fetchRecipeDetail() 함수 호출 대신 Bloc에 이벤트 추가
    _recipeDetailBloc.add(GetRecipeDetail(widget.recipeId));
  }

  // 레시피 삭제 함수
  Future<void> _deleteRecipe() async {
    // TODO: 사용자에게 삭제 확인 다이얼로그 띄우기
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레시피 삭제'),
        content: const Text('정말로 이 레시피를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 취소
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 확인
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && _recipeDetailBloc.state is RecipeDetailLoaded) { // 사용자가 확인을 누르고 레시피 데이터가 있을 때
      final loadedRecipe = (_recipeDetailBloc.state as RecipeDetailLoaded).recipe;
      debugPrint('RecipeDetailScreen: Adding DeleteRecipeRequested event for UID: ${loadedRecipe.uid}');
      // Bloc에 이벤트 추가
      _recipeActionBloc.add(DeleteRecipeRequested(uid: loadedRecipe.uid, imageUrl: loadedRecipe.photoUrl));
    } else {
      debugPrint('RecipeDetailScreen: Delete cancelled or recipe not loaded.'); // <-- 로그 추가!
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
        // 제목은 RecipeDetailBloc의 상태에서 가져옴
        title: BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
          builder: (context, state) {
            if (state is RecipeDetailLoaded) {
              return Text(state.recipe.title, style: theme.appBarTheme.titleTextStyle);
            }
            return Text('레시피 상세', style: theme.appBarTheme.titleTextStyle);
          },
        ),
        actions: [
          BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
            builder: (context, state) {
              if (state is RecipeDetailLoaded) {  // 레시피 데이터가 있고 로딩 중이 아닐 때만 표시
                // 편집 아이콘 버튼
                final loadedRecipe = state.recipe;
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return BlocProvider<RecipeActionBloc>.value( // 기존 Bloc 인스턴스 재사용
                            value: _recipeActionBloc, // RecipeActionBloc 인스턴스 전달
                            child: AddRecipeScreen(recipeToEdit: loadedRecipe),
                          );
                        },
                      ),
                    ).then((result) { // 편집 화면에서 돌아왔을 때 (결과가 있다면 목록 갱신 등)
                      if (result == true) { // 편집 성공 후 돌아왔다면 상세 정보 새로고침
                        _recipeDetailBloc.add(GetRecipeDetail(widget.recipeId));
                        // 또는 목록 화면 Provider 갱신 로직 호출
                      }
                    });
                  },
                );
              }
              return const SizedBox.shrink(); // 로딩 중 또는 에러 시 버튼 숨김
            },
          ),
          // 삭제 아이콘 버튼은 이제 Bloc의 로딩 상태를 구독
          BlocBuilder<RecipeActionBloc, RecipeActionState>(
            builder: (context, state) {
              return IconButton(
                icon: state is RecipeActionLoading ? CircularProgressIndicator(color: colorScheme.onPrimary) : const Icon(Icons.delete),
                onPressed: state is RecipeActionLoading ? null : _deleteRecipe,
              );
            },
          ),

          // 즐겨찾기 아이콘 버튼 추가
          BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
            builder: (context, state) {
              if (state is RecipeDetailLoaded) {
                final recipe = state.recipe;
                final isFavorite = recipe.isFavorite ?? false; // 즐겨찾기 상태

                return IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: isFavorite ? colorScheme.secondary : colorScheme.onPrimary, // 즐겨찾기 시 색상 변경
                  onPressed: () {
                    // Bloc에 ToggleFavoriteRequested 이벤트 추가
                    _recipeActionBloc.add(ToggleFavoriteRequested(
                      uid: recipe.uid,
                      isFavorite: isFavorite, // 현재 상태 전달
                    ));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BackgroundGradient(
        child: BlocConsumer<RecipeActionBloc, RecipeActionState>(
        listener: (context, state) {
          if (state is RecipeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? '작업이 성공적으로 완료되었습니다!'),
                backgroundColor: colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
            // 삭제 성공 시 이전 화면으로 돌아가기
            if (state.message?.contains('삭제') ?? false) { // 메시지에 '삭제' 포함 여부로 판단 (더 정확한 방법은 상태에 작업 타입 추가)
              Navigator.pop(context, true); // 이전 화면으로 돌아가면서 성공 결과(true) 전달
            }
          } else if (state is RecipeActionFailure) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('작업 실패'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          }
        },
          builder: (context, actionState) {
          return BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
            builder: (context, detailState) {
              // 상세 정보 로딩 중
              if (detailState is RecipeDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // 에러 상태 (상세 정보 로딩 에러)
              if (detailState is RecipeDetailError) {
                return EmptyErrorStateWidget( // <-- 적용!
                  message: detailState.message,
                  icon: Icons.error_outline,
                  buttonText: '다시 시도',
                  onButtonPressed: () {
                    context.read<RecipeDetailBloc>().add(GetRecipeDetail(widget.recipeId));
                  },
                  isError: true,
                );
              }
              // 상세 정보 로딩 완료
              if (detailState is RecipeDetailLoaded) {
                final recipe = detailState.recipe;  // 로드된 레시피 데이터

                // RecipeActionBloc의 로딩 상태 (삭제/편집 작업 로딩)
                if (actionState is RecipeActionLoading) { // RecipeActionBloc의 로딩 상태가 우선
                  return const Center(child: CircularProgressIndicator());
                }

                // 모든 로딩/에러/빈 상태가 아니면 상세 정보 표시
                return ListView( // 레시피 데이터가 있으면 상세 정보 표시
                  padding: const EdgeInsets.all(kDefaultPadding),
                  children: [
                    // 레시피 사진
                    if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kSpacingMedium),
                        child: CachedNetworkImage( // 이미지 캐싱 패키지
                          imageUrl: recipe.photoUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error_outline, size: 50),
                        ),
                      )
                    else
                    // 사진 없을 때 Placeholder
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.image_not_supported, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                      ),

                    const SizedBox(height: kSpacingMedium),

                    // 레시피 제목
                    Text(
                      recipe.title,
                      style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface), // 테마에서 제목 스타일 가져오기
                    ),

                    // 카테고리 표시
                    if (recipe.category != null && recipe.category!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingSmall),
                        child: Row(
                          children: [
                            Icon(Icons.category, size: kIconSizeMedium, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: kSpacingSmall),
                            Text('카테고리: ${recipe.category}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),

                    // 태그 표시
                    if (recipe.tags != null && recipe.tags!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingMedium),
                        child: Wrap(
                          spacing: kSpacingSmall,
                          runSpacing: kSpacingSmall,
                          children: recipe.tags!
                              .map((tag) => Chip(
                            label: Text(tag, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSecondaryContainer)),
                            backgroundColor: colorScheme.secondaryContainer,
                          ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: kSpacingLarge),

                    // 재료 목록 섹션
                    Text('재료', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                    const SizedBox(height: kSpacingSmall),
                    // TODO: 재료 목록 (List<String> ingredients; 이런 식으로 RecipeEntity에 있다면)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients?.map((ingredient) => Text('- $ingredient', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))).toList() ?? [], // bodyMedium 스타일, onSurface 색상
                    ),

                    const SizedBox(height: kSpacingLarge),

                    // TODO: 조리법 단계별 목록 (List<String> steps; 이런 식으로 RecipeEntity에 있다면)
                    // 조리법 섹션
                    Text('조리법', style: textTheme.titleMedium), // 테마 스타일 활용
                    const SizedBox(height: kSpacingSmall), // 상수 사용
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.steps?.asMap().entries.map((entry) {
                        int stepNum = entry.key + 1;
                        String stepText = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: kSpacingExtraSmall), // 상수 사용
                          child: Text('$stepNum. $stepText', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)), // bodyMedium 스타일, onSurface 색상
                        );
                      }).toList() ?? [],
                    ),
                    // TODO: 필요한 온도, 시간, 팁 등 추가 정보 표시
                  ],
                );
              }
              // 초기 상태 또는 알 수 없는 상태 (레시피를 찾을 수 없음)
              return EmptyErrorStateWidget( // <-- 적용!
                message: '레시피를 찾을 수 없습니다.',
                icon: Icons.search_off, // 또는 Icons.menu_book
                // buttonText: '목록으로 돌아가기',
                // onButtonPressed: () { Navigator.pop(context); },
              );
            },
          );
          },
        ),
      ),
    );
  }
}
