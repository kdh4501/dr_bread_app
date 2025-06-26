import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_contstants.dart';
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
  // 상세 레시피 데이터 상태 (초기에는 null)
  RecipeEntity? _recipe;
  bool _isLoading = false;
  String? _errorMessage;

  // 나중에 main.dart 또는 DI 설정에서 주입받거나 Provider로 접근
  late final GetRecipeDetailUseCase _getRecipeDetailUseCase;
  // Bloc 인스턴스 가져오기
  late final RecipeActionBloc _recipeActionBloc;  // RecipeActionBloc: 레시피 추가/편집/삭제 작업의 로딩, 성공, 실패 상태를 관리.

  @override
  void initState() {
    super.initState();
    _getRecipeDetailUseCase = getIt<GetRecipeDetailUseCase>();
    // Bloc 인스턴스 가져오기
    _recipeActionBloc = context.read<RecipeActionBloc>();

    _fetchRecipeDetail(); // 화면 로딩 시 상세 데이터 가져오기
  }

  // 레시피 상세 데이터 가져오는 비동기 함수
  Future<void> _fetchRecipeDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // UseCase 실행
      final result = await _getRecipeDetailUseCase(widget.recipeId); // call() 메서드에 ID 전달
      setState(() {
        _recipe = result; // 데이터 업데이트
      });
    } catch (e) {
      setState(() {
        _errorMessage = '레시피 상세 정보를 불러오는데 실패했습니다: $e'; // 에러 메시지
      });
      debugPrint('레시피 상세 로딩 중 에러 발생: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
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

    if (confirmed == true && _recipe != null) { // 사용자가 확인을 누르고 레시피 데이터가 있을 때
      // Bloc에 이벤트 추가
      _recipeActionBloc.add(DeleteRecipeRequested(uid: _recipe!.uid, imageUrl: _recipe!.photoUrl));
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe?.title ?? '레시피 상세'), // 레시피 제목 또는 기본 제목
        actions: [
          // 편집 아이콘 버튼
          if (_recipe != null && !_isLoading) // 레시피 데이터가 있고 로딩 중이 아닐 때만 표시
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: 레시피 편집 화면으로 이동 (편집할 레시피 데이터 또는 ID 전달)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final addRecipeUseCase = getIt<AddRecipeUseCase>();
                      final updateRecipeUseCase = getIt<UpdateRecipeUseCase>();
                      final getRecipeDetailUseCase = getIt<GetRecipeDetailUseCase>();
                      final uploadImageUseCase = getIt<UploadImageUseCase>();

                      return BlocProvider<RecipeActionBloc>.value( // 기존 Bloc 인스턴스 재사용
                        value: _recipeActionBloc, // RecipeActionBloc 인스턴스 전달
                        child: AddRecipeScreen(recipeToEdit: _recipe!),
                      );
                    },
                  ),
                ).then((result) { // 편집 화면에서 돌아왔을 때 (결과가 있다면 목록 갱신 등)
                  if (result == true) { // 편집 성공 후 돌아왔다면 상세 정보 새로고침 (옵션)
                    _fetchRecipeDetail();
                    // 또는 목록 화면 Provider 갱신 로직 호출
                  }
                });
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
        ],
      ),
      body:  BlocConsumer<RecipeActionBloc, RecipeActionState>(
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
        builder: (context, state) {
          // _fetchRecipeDetail의 로딩 상태를 먼저 확인
          if (_isLoading) { // 상세 정보 로딩 중
            return const Center(child: CircularProgressIndicator());
          }

          // RecipeActionBloc의 로딩 상태 (삭제/편집 작업 로딩)
          if (state is RecipeActionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 상태 (상세 정보 로딩 에러)
          if (_errorMessage != null) {
            return Center(child: Text(_errorMessage!));
          }
          // 레시피 데이터가 없는 경우
          if (_recipe == null) {
            return const Center(child: Text('레시피를 찾을 수 없습니다.'));
          }
          return ListView( // 레시피 데이터가 있으면 상세 정보 표시
            padding: const EdgeInsets.all(kDefaultPadding),
            children: [
              // 레시피 사진
              if (_recipe!.photoUrl != null && _recipe!.photoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(kSpacingMedium),
                  child: CachedNetworkImage( // 이미지 캐싱 패키지
                    imageUrl: _recipe!.photoUrl!,
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
                _recipe!.title,
                style: textTheme.titleLarge, // 테마에서 제목 스타일 가져오기
              ),

              // TODO: 간단 설명, 카테고리, 소요 시간 등 추가 정보 표시

              const SizedBox(height: kSpacingLarge),

              // 재료 목록 섹션
              Text('재료', style: textTheme.titleMedium),
              const SizedBox(height: kSpacingSmall),
              // TODO: 재료 목록 (List<String> ingredients; 이런 식으로 RecipeEntity에 있다면)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _recipe!.ingredients?.map((ingredient) => Text('- $ingredient', style: textTheme.bodyMedium)).toList() ?? [],
              ),
              const Text('- (재료 목록 표시)'), // Placeholder

              const SizedBox(height: kSpacingLarge),

              // 조리법 섹션
              Text('조리법', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              // TODO: 조리법 단계별 목록 (List<String> steps; 이런 식으로 RecipeEntity에 있다면)
              // 조리법 섹션
              Text('조리법', style: textTheme.titleMedium), // 테마 스타일 활용
              const SizedBox(height: kSpacingSmall), // 상수 사용
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _recipe!.steps?.asMap().entries.map((entry) {
                  int stepNum = entry.key + 1;
                  String stepText = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: kSpacingExtraSmall), // 상수 사용
                    child: Text('$stepNum. $stepText', style: textTheme.bodyMedium), // 테마 스타일 활용
                  );
                }).toList() ?? [],
              ),
              // TODO: 필요한 온도, 시간, 팁 등 추가 정보 표시
            ],
          );
        },
      )
    );
  }
}
