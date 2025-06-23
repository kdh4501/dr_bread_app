import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_contstants.dart';
import '../../../../main.dart';
import '../../domain/entities/recipe.dart';
// TODO: 레시피 추가 UseCase 임포트
import '../../domain/usecases/add_recipe_usecase.dart'; // UseCase
// TODO: 레시피 업데이트 UseCase 임포트
import '../../domain/usecases/get_recipe_detail_usecase.dart';
import '../../domain/usecases/update_recipe_usecase.dart'; // UseCase
// TODO: 이미지 피커 패키지 임포트
import 'package:image_picker/image_picker.dart';

import '../../domain/usecases/upload_image_usecase.dart';   // image_picker 패키지

// TODO: Firebase Storage 관련 UseCase (이미지 업로드) 필요시 임포트

/*
AddRecipeScreen 레시피 입력/수정 화면
 */
class AddRecipeScreen extends StatefulWidget {
  // 편집 모드일 경우 전달받을 기존 레시피 데이터 (선택 사항)
  final RecipeEntity? recipeToEdit;

  // recipeToEdit이 null이면 추가 모드, null이 아니면 편집 모드
  const AddRecipeScreen({Key? key, this.recipeToEdit}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  // 폼 입력을 관리하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  // 입력 필드 컨트롤러들
  late TextEditingController _titleController;
  // TODO: 카테고리, 소요 시간 등 다른 입력 필드 컨트롤러

  // 동적 목록 (재료, 조리법)을 관리하기 위한 리스트와 컨트롤러
  // 예시: 재료 목록 (String 형태로 관리)
  final List<TextEditingController> _ingredientControllers = [];
  // 예시: 조리법 단계 목록 (String 형태로 관리)
  final List<TextEditingController> _stepControllers = [];

  // 선택된 이미지 파일 상태
  XFile? _selectedImage; // image_picker 패키지 사용

  // 로딩 상태 (저장/업데이트 중)
  bool _isLoading = false;

  // TODO: UseCase 인스턴스 선언 (DI 필요)
  late final AddRecipeUseCase _addRecipeUseCase;
  late final UpdateRecipeUseCase _updateRecipeUseCase;
  late final GetRecipeDetailUseCase _getRecipeDetailUseCase; // 편집 모드 데이터 로딩용
  late final UploadImageUseCase _uploadImageUseCase; // 이미지 업로드용
  // TODO: 이미지 업로드 UseCase (Storage 연동) 필요시 선언

  RecipeEntity? _recipe;

  // 편집 모드인지 확인
  bool get isEditing => widget.recipeToEdit != null;

  @override
  void initState() {
    super.initState();
    // TODO: DI 설정에서 UseCase 인스턴스 가져오기
    _addRecipeUseCase = getIt<AddRecipeUseCase>();
    _updateRecipeUseCase = getIt<UpdateRecipeUseCase>();
    _getRecipeDetailUseCase = getIt<GetRecipeDetailUseCase>();
    _uploadImageUseCase = getIt<UploadImageUseCase>();

    // TODO: 이미지 업로드 UseCase 가져오기

    // 컨트롤러 초기화
    _titleController = TextEditingController();
    // TODO: 다른 컨트롤러 초기화

    // 편집 모드인 경우 기존 데이터로 필드 초기화
    if (isEditing) {
      _recipe = widget.recipeToEdit;
      _titleController.text = _recipe!.title;
      if(_recipe!.ingredients != null) {
        for (var ing in _recipe!.ingredients!) {
          _ingredientControllers.add(TextEditingController(text: ing));
        }
      }
      if (_recipe!.steps != null) {
        for (var step in _recipe!.steps!) {
          _stepControllers.add(TextEditingController(text: step));
        }
      }
      // TODO: 기존 이미지 URL 처리 (_selectedImage 대신 photoUrl 사용)
      // _selectedImage = null; // 편집 모드에서는 기존 이미지는 _recipe.photoUrl로 관리
    } else {
      // 추가 모드인 경우 기본 입력 필드 추가 (예: 재료 1개, 조리법 1단계)
      _titleController = TextEditingController();
      _ingredientControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
    }
  }

  // 컨트롤러 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _titleController.dispose();
    // TODO: 다른 컨트롤러 해제
    // 동적 목록 컨트롤러들도 모두 해제
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 이미지 선택 함수 (갤러리 또는 카메라)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 선택

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile; // 선택된 이미지 파일 상태 업데이트
      });
    }
  }

  // 재료 입력 필드 동적 추가
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  // 재료 입력 필드 동적 삭제
  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose(); // 컨트롤러 해제
      _ingredientControllers.removeAt(index); // 목록에서 제거
    });
  }

  // 조리법 입력 필드 동적 추가
  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  // 조리법 입력 필드 동적 삭제
  void _removeStepField(int index) {
    setState(() {
      _stepControllers[index].dispose(); // 컨트롤러 해제
      _stepControllers.removeAt(index); // 목록에서 제거
    });
  }


  // 입력된 데이터를 모아서 저장/업데이트 처리
  Future<void> _saveRecipe() async {
    // 폼 유효성 검사
    if (_formKey.currentState!.validate()) {
      // 폼 필드 값 저장
      _formKey.currentState!.save();

      // TODO: 입력된 데이터를 RecipeEntity 객체 또는 Map 형태로 만들기
      // 재료 목록, 조리법 단계는 컨트롤러 리스트에서 값을 가져와 List<String> 등으로 변환
      final String title = _titleController.text;
      final List<String> ingredients = _ingredientControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList(); // 빈 값 제외
      final List<String> steps = _stepControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList(); // 빈 값 제외

      // TODO: 선택된 이미지 파일 업로드 로직 (Firebase Storage 사용)
      // 이미지를 Storage에 업로드하고 다운로드 URL을 받아와야 함.
      String? imageUrl;
      if (_selectedImage != null) {
        // TODO: 이미지 업로드 UseCase 호출
        final imageFile = File(_selectedImage!.path);

        // TODO: Storage에 저장될 경로 생성 (예: 'recipe_images/사용자UID/레시피UID_timestamp.jpg')
        // 사용자 UID는 FirebaseAuth.instance.currentUser?.uid 로 가져올 수 있음
        // 레시피 UID는 새 레시피 추가 시에는 Firestore가 생성, 편집 시에는 기존 레시피 UID 사용
        // 경로 생성 로직은 UseCase나 Repository에서 처리하는 것이 더 적합할 수 있음.
        final String uploadPath = '$kRecipeImagesStoragePath/${getIt<FirebaseAuth>().currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg'; // <-- 상수 활용!

        // UploadImageUseCase 실행!
        imageUrl = await _uploadImageUseCase.call(imageFile, uploadPath); // <-- UseCase 실행!
      } else if (isEditing && _recipe != null && _recipe!.photoUrl != null) {
        // 편집 모드이고 새 이미지 선택 안했으면 기존 이미지 URL 사용
        imageUrl = _recipe!.photoUrl;
      }


      // RecipeEntity 객체 생성 (업데이트 시 기존 UID 사용)
      final RecipeEntity recipeToSave = RecipeEntity(
        uid: isEditing ? _recipe!.uid : '새 UID', // TODO: 새 레시피는 Firestore가 생성하는 UID 사용 또는 UseCase에서 처리
        title: title,
        ingredients: ingredients, // TODO: Entity에 ingredients 필드 추가 필요
        steps: steps, // TODO: Entity에 steps 필드 추가 필요
        photoUrl: imageUrl,
        // TODO: 카테고리, 작성자 (현재 로그인 사용자 UID), 생성/수정 날짜 등 추가 필드
      );

      setState(() { _isLoading = true; }); // 로딩 시작

      try {
        if (isEditing) {
          // 기존 레시피 업데이트 UseCase 실행
          await _updateRecipeUseCase(recipeToSave); // call() 메서드 호출
        } else {
          // 새 레시피 추가 UseCase 실행
          await _addRecipeUseCase(recipeToSave); // call() 메서드 호출
        }

        // TODO: 저장/업데이트 성공 후 처리 (예: 이전 화면으로 돌아가기)
        // 1. 성공 메시지 표시 (스낵바 추천)
        ScaffoldMessenger.of(context).showSnackBar( // ScaffoldMessenger 사용
          SnackBar(
            content: Text(isEditing ? '레시피가 수정되었습니다!' : '레시피가 추가되었습니다!'), // 메시지 내용
            backgroundColor: Theme.of(context).colorScheme.primary, // 테마 메인 색상 활용
            duration: const Duration(seconds: 2), // 2초 동안 표시
          ),
        );

        // 2. 화면 전환 (이전 화면으로 돌아가기)
        Navigator.pop(context, true); // 이전 화면으로 돌아가면서 성공 결과(true) 전달

        // TODO: SnackBar 등으로 사용자에게 저장 완료 알림 (옵션)

      } catch (e) {
        // TODO: 저장/업데이트 실패 시 에러 처리
        setState(() { _isLoading = false; }); // 로딩 종료
        // 에러 메시지 다이얼로그 등으로 보여주기
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isEditing ? '레시피 수정 실패' : '레시피 추가 실패'),
            content: Text('오류가 발생했습니다: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        debugPrint('레시피 저장/업데이트 중 에러 발생: $e');
      }
      // 로딩 종료는 에러 발생 시 또는 성공 후 pop 될 때 setState를 통해 자연스럽게 처리될 수 있음
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '레시피 편집' : '새 레시피 추가'), // 모드에 따라 제목 변경
        actions: [
          // 저장 버튼
          IconButton(
            icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save), // 로딩 중이면 스피너, 아니면 저장 아이콘
            onPressed: _isLoading ? null : _saveRecipe, // 로딩 중에는 버튼 비활성화
          ),
        ],
      ),
      body: _isLoading && !isEditing && _recipe == null // 추가 모드 초기 로딩은 없으니 이렇게 체크 (편집 모드는 상세에서 로딩 처리)
          ? const Center(child: CircularProgressIndicator()) // 여기서는 거의 볼일 없음
          : Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form( // 폼 위젯 사용
          key: _formKey, // 폼 키 연결
          child: ListView( // 스크롤 가능하도록 ListView 사용
            children: [
              // 레시피 사진 선택/미리보기
              GestureDetector( // 이미지를 탭하면 선택
                onTap: _pickImage,
                child: Card(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    child: _selectedImage != null // 새 이미지 선택 시 미리보기
                        ? ClipRRect( // 이미지 자체도 모서리 둥글게 (Card 모서리 둥글기와 일치 또는 살짝 작게)
                      borderRadius: BorderRadius.circular(theme.cardTheme.shape is RoundedRectangleBorder ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context)).topLeft.x - 1.0 : 0.0), // Card 테마 둥글기 값 가져와서 적용
                      child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                    )
                        : isEditing && _recipe != null && _recipe!.photoUrl != null // 편집 모드이고 기존 이미지 있을 때
                        ? ClipRRect( // 이미지 자체도 모서리 둥글게
                      borderRadius: BorderRadius.circular(theme.cardTheme.shape is RoundedRectangleBorder ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context)).topLeft.x - 1.0 : 0.0), // Card 테마 둥글기 값 가져와서 적용
                      child: CachedNetworkImage( // 기존 이미지 미리보기
                        imageUrl: _recipe!.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                      ),
                    )
                        : Column( // 사진 없을 때 기본 UI
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: kIconSizeLarge, color: colorScheme.onSurfaceVariant),
                        SizedBox(height: kSpacingSmall),
                        Text(
                            '사진 추가',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                        ),
                      ],
                    ),
                  )
                ),
              ),
              const SizedBox(height: kSpacingMedium),

              // 제목 입력 필드
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '레시피 제목',
                ),
                validator: (value) { // 유효성 검사 (비어있으면 에러 메시지)
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null; // 유효함
                },
              ),
              const SizedBox(height: kSpacingMedium),

              // TODO: 카테고리 선택 DropdownButton 또는 다른 필드들 추가

              // 재료 입력 섹션 (동적 목록)
              Text('재료', style: textTheme.titleMedium),
              const SizedBox(height: kSpacingSmall),
              ListView.builder( // 재료 입력 필드 목록
                shrinkWrap: true, // ListView를 Column 안에 넣을 때 필요
                physics: NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                itemCount: _ingredientControllers.length,
                itemBuilder: (context, index) {
                  // 각 재료 입력 필드 및 삭제 버튼
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientControllers[index],
                          decoration: InputDecoration(
                            hintText: '예: 강력분 200g', // 힌트 텍스트
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15), // 패딩 조정
                          ),
                          // validator: (value) { if (value == null || value.isEmpty) return '재료를 입력하세요'; return null; }, // 재료는 필수가 아닐 수도 있으니 주석처리
                        ),
                      ),
                      // 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.redAccent,
                        onPressed: () => _removeIngredientField(index),
                      ),
                    ],
                  );
                },
              ),
              // 재료 추가 버튼
              TextButton(
                onPressed: _addIngredientField,
                child: const Text('+ 재료 추가'),
              ),
              const SizedBox(height: 16),

              // 조리법 입력 섹션 (동적 목록)
              Text('조리법', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: kSpacingSmall),
              ListView.builder( // 조리법 단계 입력 필드 목록
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _stepControllers.length,
                itemBuilder: (context, index) {
                  // 각 단계 입력 필드 및 삭제 버튼
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 단계 번호 표시
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, right: kSpacingSmall),
                        child: Text('${index + 1}.', style: textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _stepControllers[index],
                          decoration: InputDecoration(
                            hintText: '예: 오븐을 180도로 예열합니다.',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15), // 패딩 조정
                          ),
                          maxLines: null, // 여러 줄 입력 가능
                          keyboardType: TextInputType.multiline, // 멀티라인 키보드
                          // validator: (value) { if (value == null || value.isEmpty) return '조리 단계를 입력하세요'; return null; }, // 조리 단계는 필수가 아닐 수도 있으니 주석처리
                        ),
                      ),
                      // 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.redAccent,
                        onPressed: () => _removeStepField(index),
                      ),
                    ],
                  );
                },
              ),
              // 조리법 단계 추가 버튼
              TextButton(
                onPressed: _addStepField,
                child: const Text('+ 조리 단계 추가'),
              ),

              // TODO: 필요한 온도, 시간, 팁 등 추가 입력 필드

              const SizedBox(height: kSpacingExtraLarge), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }
}
