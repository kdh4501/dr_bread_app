import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../domain/entities/recipe.dart'; // RecipeEntity 임포트
// TODO: 상세 레시피 조회 UseCase 임포트
import '../../domain/usecases/get_recipe_detail_usecase.dart'; // UseCase
// TODO: 레시피 삭제 UseCase 임포트
import '../../domain/usecases/delete_recipe_usecase.dart'; // UseCase
// TODO: 레시피 편집 화면 임포트
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

  // TODO: UseCase 인스턴스 선언 (DI 필요)
  // 나중에 main.dart 또는 DI 설정에서 주입받거나 Provider로 접근
  late final GetRecipeDetailUseCase _getRecipeDetailUseCase;
  late final DeleteRecipeUseCase _deleteRecipeUseCase;

  @override
  void initState() {
    super.initState();
    // TODO: DI 설정에서 UseCase 인스턴스 가져오기 (Provider 또는 get_it 사용)
    // 예시: Provider 사용 시
    _getRecipeDetailUseCase = Provider.of<GetRecipeDetailUseCase>(context, listen: false);
    _deleteRecipeUseCase = Provider.of<DeleteRecipeUseCase>(context, listen: false);

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
      setState(() { _isLoading = true; }); // 로딩 시작 (삭제 로딩)
      try {
        await _deleteRecipeUseCase(_recipe!.uid); // UseCase 실행 (ID 전달)
        // TODO: 삭제 성공 후 처리 (예: 이전 화면인 목록 화면으로 돌아가기)
        Navigator.pop(context); // 상세 화면 닫고 목록 화면으로 복귀
        // TODO: SnackBar 등으로 사용자에게 삭제 완료 알림 (옵션)

      } catch (e) {
        // TODO: 삭제 실패 시 에러 처리 (에러 메시지 보여주기 등)
        setState(() { _errorMessage = '레시피 삭제에 실패했습니다: $e'; });
        debugPrint('레시피 삭제 중 에러 발생: $e');
      } finally {
        setState(() { _isLoading = false; }); // 로딩 종료
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => AddRecipeScreen(recipeToEdit: _recipe!), // RecipeEntity 객체 전달
                  ),
                ).then((result) { // 편집 화면에서 돌아왔을 때 (결과가 있다면 목록 갱신 등)
                  if (result == true) { // 편집 성공 후 돌아왔다면 상세 정보 새로고침 (옵션)
                    _fetchRecipeDetail();
                    // 또는 목록 화면 Provider 갱신 로직 호출
                  }
                });
              },
            ),
          // 삭제 아이콘 버튼
          if (_recipe != null && !_isLoading) // 레시피 데이터가 있고 로딩 중이 아닐 때만 표시
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteRecipe, // 삭제 함수 호출
            ),
        ],
      ),
      body: _isLoading // 로딩 중이면 로딩 스피너
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null // 에러 발생 시 에러 메시지
          ? Center(child: Text(_errorMessage!))
          : _recipe == null // 레시피 데이터가 없는 경우 (ID는 받았지만 못 찾은 경우)
          ? const Center(child: Text('레시피를 찾을 수 없습니다.'))
          : ListView( // 레시피 데이터가 있으면 상세 정보 표시
        padding: const EdgeInsets.all(16.0),
        children: [
          // 레시피 사진
          if (_recipe!.photoUrl != null && _recipe!.photoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
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
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
            ),

          const SizedBox(height: 16),

          // 레시피 제목
          Text(
            _recipe!.title,
            style: Theme.of(context).textTheme.titleLarge, // 테마에서 제목 스타일 가져오기
          ),

          // TODO: 간단 설명, 카테고리, 소요 시간 등 추가 정보 표시

          const SizedBox(height: 20),

          // 재료 목록 섹션
          Text('재료', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // TODO: 재료 목록 (List<String> ingredients; 이런 식으로 RecipeEntity에 있다면)
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: _recipe!.ingredients!.map((ingredient) => Text('- $ingredient')).toList(),
          // ),
          const Text('- (재료 목록 표시)'), // Placeholder

          const SizedBox(height: 20),

          // 조리법 섹션
          Text('조리법', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // TODO: 조리법 단계별 목록 (List<String> steps; 이런 식으로 RecipeEntity에 있다면)
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: _recipe!.steps!.asMap().entries.map((entry) {
          //     int stepNum = entry.key + 1;
          //     String stepText = entry.value;
          //     return Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 4.0),
          //       child: Text('$stepNum. $stepText'),
          //     );
          //   }).toList(),
          // ),
          const Text('1. (첫 번째 조리 단계)'), // Placeholder
          const Text('2. (두 번째 조리 단계)'), // Placeholder

          // TODO: 필요한 온도, 시간, 팁 등 추가 정보 표시
        ],
      ),
    );
  }
}
