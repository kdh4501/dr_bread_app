import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:dr_bread_app/features/recipe/presentation/bloc/recipe_detail_state.dart';
import 'package:dr_bread_app/features/recipe/presentation/screens/photo_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
// TODO: 상세 레시피 조회 UseCase 임포트
import '../../domain/entities/review.dart';
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
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/empty_error_state_widget.dart';
import '../widgets/rating_bar_widget.dart';
import '../widgets/review_item_widget.dart';
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
  late final ReviewBloc _reviewBloc;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    // Bloc 인스턴스 가져오기
    _recipeActionBloc = context.read<RecipeActionBloc>();
    _recipeDetailBloc = context.read<RecipeDetailBloc>();
    _reviewBloc = context.read<ReviewBloc>();
    _authBloc = context.read<AuthBloc>();

    // 화면 로딩 시 상세 데이터 가져오기
    // _fetchRecipeDetail() 함수 호출 대신 Bloc에 이벤트 추가
    _recipeDetailBloc.add(GetRecipeDetail(widget.recipeId));
    _reviewBloc.add(GetReviews(widget.recipeId));
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

  void _showReviewInputDialog(
      BuildContext context,
      String recipeId,
      UserEntity currentUser, {
      ReviewEntity? existingReview,  // 기존 리뷰가 있을 경우 (수정 모드)
      }) {
    final TextEditingController reviewController = TextEditingController(text: existingReview?.reviewText ?? '');
    double currentRating = 3.0; // 기본 평점

    showDialog(
      context: context,
      builder: (context) => AlertDialog( // DialogTheme 자동 적용
        title: Text(existingReview != null ? '리뷰 수정' : '리뷰 작성'),
        content: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('평점', style: Theme.of(context).textTheme.titleMedium),
              RatingBarWidget(
                rating: currentRating,
                onRatingUpdate: (rating) {
                  currentRating = rating;
                },
                itemSize: 30, // 다이얼로그에서는 좀 더 크게
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: kSpacingMedium),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  labelText: '리뷰 내용',
                  hintText: '레시피에 대한 의견을 남겨주세요.',
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reviewController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
                );
                return;
              }
              final newReview = ReviewEntity(
                uid: existingReview?.uid ?? '', // 수정 시 기존 UID 사용, 작성 시에는 '' (Firestore에서 자동 생성)
                recipeId: recipeId,
                authorUid: currentUser.uid,
                authorDisplayName: currentUser.displayName,
                authorPhotoUrl: currentUser.photoUrl,
                rating: currentRating,
                reviewText: reviewController.text.trim(),
                createdAt: existingReview?.createdAt ?? DateTime.now(), // 수정 시 기존 생성 시간 유지
              );

              if (existingReview != null) {
                _reviewBloc.add(UpdateReview(newReview)); // 리뷰 수정 이벤트
              } else {
                _reviewBloc.add(AddReview(newReview)); // 리뷰 추가 이벤트
              }
              Navigator.pop(context); // 다이얼로그 닫기
            },
            child: const Text('작성'),
          ),
        ],
      ),
    ).then((_) {
      reviewController.dispose(); // 컨트롤러 dispose
    });
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
                    // 레시피 카드 클릭 시 상세 화면으로 이동
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => BlocProvider<RecipeActionBloc>.value(
                          value: _recipeActionBloc,
                          child: AddRecipeScreen(recipeToEdit: loadedRecipe),
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
                        _recipeDetailBloc.add(GetRecipeDetail(widget.recipeId));
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
                  color: isFavorite ? colorScheme.primary : colorScheme.onPrimary, // 즐겨찾기 시 색상 변경
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
            }// 즐겨찾기 토글 성공 시 RecipeDetailBloc에게 데이터 갱신 요청
            else if (state.id == widget.recipeId) { // 현재 화면의 레시피 ID와 일치할 경우
              _recipeDetailBloc.add(GetRecipeDetail(widget.recipeId)); // 상세 정보 다시 가져오기
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
          // 리뷰 추가/수정/삭제 성공 시 리뷰 목록 갱신 이벤트 추가
          if (state is RecipeActionSuccess && state.message?.contains('리뷰') == true) {
            _reviewBloc.add(GetReviews(widget.recipeId)); // 리뷰 목록 새로고침
          }
        },
          builder: (context, actionState) {
          return BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
            builder: (context, detailState) {
              // 상세 정보 로딩 중
              if (detailState is RecipeDetailLoading) {
                return const CustomLoadingIndicator();
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
                  return CustomLoadingIndicator(
                    backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.8), // 로딩 중 화면 위에 배경색
                  );
                }

                // 모든 로딩/에러/빈 상태가 아니면 상세 정보 표시
                return ListView( // 레시피 데이터가 있으면 상세 정보 표시
                  padding: const EdgeInsets.all(kDefaultPadding),
                  children: [
                    // 레시피 사진
                    if (recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                            PageRouteBuilder( // 부드러운 화면 전환
                              pageBuilder: (context, animation, secondaryAnimation) => PhotoViewScreen(imageUrl: recipe.photoUrl!),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child); // 페이드 전환
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'recipeImage_${recipe.uid}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(kSpacingMedium),
                            child: CachedNetworkImage( // 이미지 캐싱 패키지
                              imageUrl: recipe.photoUrl!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 250,
                                color: colorScheme.surfaceVariant,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 250,
                                color: colorScheme.surfaceVariant,
                                child: Icon(Icons.broken_image, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
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

                    const SizedBox(height: kSpacingLarge),
                    Divider(color: colorScheme.outlineVariant), // 구분선
                    const SizedBox(height: kSpacingLarge),

                    // ↓↓↓↓↓ 리뷰 및 평점 섹션 ↓↓↓↓↓
                    Text('리뷰 및 평점', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
                    const SizedBox(height: kSpacingMedium),

                    // 평균 평점 표시
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RatingBarWidget(
                          rating: recipe.averageRating ?? 0.0, // 평균 평점
                          itemSize: 24,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: kSpacingSmall),
                        Text(
                          '${recipe.averageRating?.toStringAsFixed(1) ?? '0.0'} (${recipe.reviewCount ?? 0}개 리뷰)',
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 리뷰 작성 버튼 (로그인된 사용자만)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (authState is AuthAuthenticated) {
                          return ElevatedButton(
                            onPressed: () {
                              _showReviewInputDialog(context, recipe.uid, authState.user); // 리뷰 작성 다이얼로그 띄우기
                            },
                            child: const Text('리뷰 작성하기'),
                          );
                        }
                        return TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('리뷰 작성은 로그인 후 이용 가능합니다.')),
                            );
                          },
                          child: const Text('로그인 후 리뷰 작성'),
                        );
                      },
                    ),
                    const SizedBox(height: kSpacingLarge),

                    // 리뷰 목록 표시
                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, reviewState) {
                        if (reviewState is ReviewLoading) {
                          return const CustomLoadingIndicator(size: 100);
                        }
                        if (reviewState is ReviewError) {
                          final userFriendlyMessage = '리뷰를 불러오는 데 문제가 발생했습니다.\n잠시 후 다시 시도해 주세요.';
                          // 실제 에러 메시지(reviewState.errorMessage)는 콘솔이나 로깅 서비스로!
                          debugPrint('리뷰 로딩 오류: ${reviewState.errorMessage}');

                          return EmptyErrorStateWidget(
                            message: userFriendlyMessage,
                            icon: Icons.error_outline,
                            buttonText: '다시 시도',
                              onButtonPressed: () {
                                // RecipeDetailBloc의 detailState가 RecipeDetailLoaded일 때만 접근 가능
                                final currentRecipeId = (context.read<RecipeDetailBloc>().state as RecipeDetailLoaded).recipe.uid;
                            _reviewBloc.add(GetReviews(currentRecipeId)); // 현재 레시피 ID로 다시 리뷰 불러오기
                          },
                            isError: true,
                          );
                        }
                        if (reviewState is ReviewLoaded) {
                          // 리뷰 목록이 비어있는 경우
                          if (reviewState.reviews.isEmpty) {
                            // 현재 레시피 정보 가져오기 (이전 BlocBuilder에서 제공된 recipe가 유효함)
                            final RecipeEntity currentRecipe = (context.read<RecipeDetailBloc>().state as RecipeDetailLoaded).recipe;
                            // 현재 로그인 사용자 정보 가져오기
                            final currentUserState = _authBloc.state;
                            final String? currentUserUid = (currentUserState is AuthAuthenticated) ? currentUserState.user.uid : null;

                            // 레시피 소유 여부 판단
                            final bool isMyRecipe = (currentUserUid != null && currentUserUid == currentRecipe.authorUid);
                            // 로그인 여부 판단
                            final bool isLoggedIn = currentUserState is AuthAuthenticated;

                            String emptyReviewMessage;
                            String emptyReviewIcon;
                            String? buttonText;
                            VoidCallback? onButtonPressed;

                            if (isMyRecipe) {
                              // Case 1: 내 레시피 && 리뷰 없음
                              emptyReviewMessage = '아직 이 레시피에 대한 리뷰가 없어요.\n다른 분들의 소중한 리뷰를 기다리고 있습니다!';
                              emptyReviewIcon = 'assets/lottie/rate_review.json'; // 또는 Icons.hourglass_empty, Icons.people_outline
                            } else if (isLoggedIn) {
                              // Case 2: 내 레시피 아님 && 로그인됨 && 리뷰 없음
                              emptyReviewMessage = '아직 리뷰가 없어요.\n첫 리뷰를 남겨보세요!';
                              emptyReviewIcon = 'assets/lottie/rate_review.json';
                            } else {
                              // Case 3: 내 레시피 아님 && 로그인 안 됨 && 리뷰 없음
                              emptyReviewMessage = '로그인 후 첫 리뷰를 남길 수 있습니다.';
                              emptyReviewIcon = 'assets/lottie/lock.json'; // 잠금 아이콘 또는 로그인 아이콘
                              buttonText = '로그인하기';
                              onButtonPressed = () {
                                // 로그인 화면으로 이동 또는 로그인 플로우 시작
                                // (AuthWrapper가 최상단에 있으므로, 이 경우 보통 AuthWrapper가 로그인 상태 변화를 감지하고 LoginScreen으로 리디렉션)
                                // 여기서는 단순히 현재 화면 닫고 AuthWrapper가 동작하도록 popToRoot.
                                // 또는, 필요에 따라 LoginScreen으로 직접 push할 수 있음.
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              };
                            }

                            return EmptyErrorStateWidget(
                              message: emptyReviewMessage,
                              lottieAsset: emptyReviewIcon,
                              buttonText: buttonText,
                              onButtonPressed: onButtonPressed,
                            );
                          }

                          // 리뷰 목록이 있는 경우
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // 스크롤 막기 (부모 ListView가 스크롤)
                            itemCount: reviewState.reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviewState.reviews[index];
                              final currentUserState = _authBloc.state;
                              final currentUserUid = (_authBloc.state is AuthAuthenticated) ? (_authBloc.state as AuthAuthenticated).user.uid : null;
                              final isMyReview = currentUserUid == review.authorUid;

                              return ReviewItemWidget(
                                review: review,
                                isMyReview: isMyReview, // 내 리뷰인지 확인
                                onDelete: () {
                                  _reviewBloc.add(DeleteReview(review.uid)); // 리뷰 삭제 이벤트
                                },
                                // TODO: 리뷰 수정 기능 추가
                                onEdit: isMyReview ? () {
                                  // 해당 레시피 ID를 _showReviewInputDialog에 전달해야 함
                                  final currentRecipeId = (context.read<RecipeDetailBloc>().state as RecipeDetailLoaded).recipe.uid;
                                  _showReviewInputDialog(context, currentRecipeId, (currentUserState as AuthAuthenticated).user, existingReview: review);
                                } : null,
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
