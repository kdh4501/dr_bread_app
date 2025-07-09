import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:dr_bread_app/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart'; // Provider 사용
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../main.dart';
import '../../domain/entities/recipe.dart';
// TODO: 레시피 추가 UseCase 임포트
import '../../domain/usecases/add_recipe_usecase.dart'; // UseCase
// TODO: 레시피 업데이트 UseCase 임포트
import '../../domain/usecases/get_recipe_detail_usecase.dart';
import '../../domain/usecases/update_recipe_usecase.dart'; // UseCase
// TODO: 이미지 피커 패키지 임포트
import 'package:image_picker/image_picker.dart';

import '../../domain/usecases/upload_image_usecase.dart';
import '../bloc/recipe_action_bloc.dart';
import '../bloc/recipe_action_event.dart';
import '../bloc/recipe_action_state.dart';   // image_picker 패키지

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
  String? _selectedCategory;
  late TextEditingController _tagController;
  final List<String> _tags = [];

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
  String? _initialImageUrl; // 편집 모드일 때 기존 이미지 URL

  // Bloc 인스턴스 가져오기
  late final RecipeActionBloc _recipeActionBloc;

  RecipeEntity? _recipe;

  // 편집 모드인지 확인
  bool get isEditing => widget.recipeToEdit != null;

  @override
  void initState() {
    super.initState();
    _recipeActionBloc = context.read<RecipeActionBloc>(); // Bloc 인스턴스 가져오기

    // 컨트롤러 초기화
    _titleController = TextEditingController();
    _tagController = TextEditingController();

    // 편집 모드인 경우 기존 데이터로 필드 초기화
    if (isEditing) {
      _recipe = widget.recipeToEdit;
      _initialImageUrl = _recipe!.photoUrl;

      _titleController.text = _recipe!.title;

      _selectedCategory = _recipe!.category; // <-- 기존 카테고리 채우기
      if (_recipe!.tags != null) {
        _tags.addAll(_recipe!.tags!); // <-- 기존 태그 채우기
      }

      // 재료 목록 채우기
      if(_recipe!.ingredients != null && _recipe!.ingredients!.isNotEmpty) {
        for (var ing in _recipe!.ingredients!) {
          _ingredientControllers.add(TextEditingController(text: ing));
        }
      } else {
        _ingredientControllers.add(TextEditingController());
      }

      // 조리법 단계 채우기
      if (_recipe!.steps != null && _recipe!.steps!.isNotEmpty) {
        for (var step in _recipe!.steps!) {
          _stepControllers.add(TextEditingController(text: step));
        }
      } else {
        _stepControllers.add(TextEditingController());
      }
      // TODO: 기존 이미지 URL 처리 (_selectedImage 대신 photoUrl 사용)
      // _selectedImage = null; // 편집 모드에서는 기존 이미지는 _recipe.photoUrl로 관리
    } else {
      // 추가 모드인 경우 기본 입력 필드 추가 (예: 재료 1개, 조리법 1단계)
      _ingredientControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
    }
  }

  // 컨트롤러 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _titleController.dispose();
    // 동적 목록 컨트롤러들도 모두 해제
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    _tagController.dispose();
    super.dispose();
  }

  // 태그 추가 함수
  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
      });
    }
    _tagController.clear(); // 입력 필드 비우기
  }

  // 태그 삭제 함수
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // 이미지 선택 함수 (갤러리 또는 카메라)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 선택

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // Android UI 설정
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기',
            toolbarColor: Theme.of(context).colorScheme.primary, // 테마 메인 색상
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary, // 테마 메인 색상 위 텍스트/아이콘 색상
            initAspectRatio: CropAspectRatioPreset.ratio16x9, // 초기 자르기 비율
            lockAspectRatio: false, // 비율 고정 여부 (false면 사용자가 자유롭게 조절 가능)
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],

          ),
          // iOS UI 설정
          IOSUiSettings(
            title: '이미지 자르기',
            doneButtonTitle: '완료',
            cancelButtonTitle: '취소',
            aspectRatioLockEnabled: false, // 비율 고정 여부
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = XFile(croppedFile.path); // 선택된 이미지 파일 상태 업데이트
          _initialImageUrl = null; // 새 이미지를 선택했으니 기존 이미지 URL은 더 이상 사용 안 함
        });
      }
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

      // RecipeEntity 객체 생성 (업데이트 시 기존 UID 사용)
      final RecipeEntity recipeToSave = RecipeEntity(
        uid: isEditing ? _recipe!.uid : '', // 편집 모드일 때 기존 UID 사용, 추가 모드일 때 빈 문자열 (UseCase에서 생성)
        title: title,
        ingredients: ingredients, // TODO: Entity에 ingredients 필드 추가 필요
        steps: steps, // TODO: Entity에 steps 필드 추가 필요
        // photoUrl: isEditing ? _recipe!.photoUrl : null, // (편집 모드일 때 기존 이미지 URL 유지) <- Bloc으로 이동
        category: _selectedCategory,
        tags: _tags.isNotEmpty ? _tags : null, // 태그가 없으면 null
      );

      // Bloc에 이벤트 추가
      if (isEditing) {
        _recipeActionBloc.add(UpdateRecipeRequested(
            recipe: recipeToSave,
            imageFile: _selectedImage,
          // 기존 이미지가 있었고, _selectedImage도 null이고, _initialImageUrl도 null이면 삭제 요청
            deleteExistingImage: (_recipe?.photoUrl != null && _selectedImage == null && _initialImageUrl == null),
          // 기존 이미지 URL도 함께 전달하여 Bloc이 판단하도록 함
          currentImageUrl: _recipe?.photoUrl, // <-- 추가! 현재 레시피의 이미지 URL
        ));
      } else {
        _recipeActionBloc.add(AddRecipeRequested(
            recipe: recipeToSave,
            imageFile: _selectedImage
        ));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(isEditing ? '레시피 편집' : '새 레시피 추가', style: theme.appBarTheme.titleTextStyle), // 모드에 따라 제목 변경
        actions: [
          // 저장 버튼은 이제 Bloc의 로딩 상태를 구독
          BlocBuilder<RecipeActionBloc, RecipeActionState>(
            builder: (context, state) {
              return IconButton(
                icon: state is RecipeActionLoading ? CircularProgressIndicator(color: colorScheme.onPrimary) : const Icon(Icons.save),
                onPressed: state is RecipeActionLoading ? null : _saveRecipe,
              );
            },
          ),
        ],
      ),
      body: BackgroundGradient(
        child: GestureDetector(
        onTap: () { // 입력창 외의 영역 터치 시 키보드 내려가게
          FocusScope.of(context).unfocus();
        },
          child: BlocConsumer<RecipeActionBloc, RecipeActionState>(
            listener: (context, state) {
              if (state is RecipeActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? '작업이 성공적으로 완료되었습니다!'),
                      backgroundColor: colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    )
                );
                Navigator.pop(context, true); // 이전 화면으
              } else if (state is RecipeActionFailure){
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('작업 실패'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('확인'),
                      )
                    ],
                  ),
                );
              }
              },
            builder: (context, state) {
              // 로딩 중이면 로딩 스피너 표시 (전체 화면 로딩)
              if (state is RecipeActionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Form( // 폼 위젯 사용
                key: _formKey, // 폼 키 연결
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView( // 스크롤 가능하도록 ListView 사용
                  children: [
                    // 레시피 사진 선택/미리보기
                    GestureDetector( // 이미지를 탭하면 선택
                        onTap: _pickImage,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              border: Border.all(
                                color: colorScheme.outline,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(kSpacingMedium)
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _selectedImage != null // 새 이미지 선택 시 미리보기
                                    ? ClipRRect( // 이미지 자체도 모서리 둥글게 (Card 모서리 둥글기와 일치 또는 살짝 작게)
                                  borderRadius: BorderRadius.circular(kSpacingMedium - 1.0), // Card 테마 둥글기 값 가져와서 적용
                                  child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                )
                                // 편집 모드일 때 기존 이미지 미리보기 (새 이미지 선택 안 했을 경우)
                                    : _initialImageUrl != null && _initialImageUrl!.isNotEmpty // 기존 이미지 URL이 있다면
                                    ? ClipRRect( // 이미지 자체도 모서리 둥글게
                                  borderRadius: BorderRadius.circular(kSpacingMedium - 1.0), // Card 테마 둥글기 값 가져와서 적용
                                  child: CachedNetworkImage( // 기존 이미지 미리보기
                                    imageUrl: _initialImageUrl!,
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
                                // 이미지 삭제 버튼 추가
                                if (isEditing && (_selectedImage != null || (_initialImageUrl != null && _initialImageUrl!.isNotEmpty))) // 편집 모드이고 이미지가 있을 때만 표시
                                  Positioned( // Stack 내에서 위치 지정
                                    top: kSpacingSmall, // 상단 여백
                                    right: kSpacingSmall, // 우측 여백
                                    child: IconButton(
                                      icon: Icon(Icons.cancel, color: colorScheme.error, size: kIconSizeMedium), // 삭제 아이콘
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null; // 새로 선택된 이미지 제거
                                          _initialImageUrl = null; // 기존 이미지 URL 제거
                                        });
                                        // TODO: 사용자에게 이미지 삭제됨을 알리는 스낵바 등 피드백
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('이미지가 삭제되었습니다.'),
                                            backgroundColor: colorScheme.primary,
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
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
                          return '레시피 제목은 비어있을 수 없습니다.';
                        }
                        if (value.length < 2) {
                          return '제목은 최소 2글자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 카테고리 선택 DropdownButton 필드
                    Text('카테고리', style: textTheme.titleMedium),
                    const SizedBox(height: kSpacingSmall),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: Text(
                        '카테고리 선택',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      decoration: InputDecoration(
                        // InputDecorationTheme 자동 적용
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 패딩 조정
                      ),
                      items: ['빵', '쿠키', '케이크', '음료', '기타'] // 예시 카테고리 목록
                          .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) { // 카테고리 필수 검사
                        if (value == null || value.isEmpty) {
                          return '카테고리를 선택해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 태그 입력 필드
                    Text('태그', style: textTheme.titleMedium),
                    const SizedBox(height: kSpacingSmall),
                    TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: '예: 노오븐, 비건, 초콜릿 (쉼표로 구분)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addTag(_tagController.text);
                          },
                        ),
                      ),
                      onFieldSubmitted: (value) { // 엔터 키 입력 시 태그 추가
                        _addTag(value);
                      },
                    ),
                    const SizedBox(height: kSpacingSmall),
                    // 입력된 태그들을 Chip으로 표시
                    Wrap( // 태그들이 자동으로 줄 바꿈되도록 Wrap 사용
                      spacing: kSpacingSmall, // 태그 간 가로 간격
                      runSpacing: kSpacingSmall, // 태그 간 세로 간격
                      children: _tags
                          .map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: Icon(Icons.cancel),
                        onDeleted: () => _removeTag(tag),
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: kSpacingMedium),

                    // 재료 입력 섹션 (동적 목록)
                    Text('재료', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
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
                                ),
                                validator: (value) { return null; },
                              ),
                            ),
                            // 삭제 버튼
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: colorScheme.error,
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
                    const SizedBox(height: kSpacingMedium),

                    // 조리법 입력 섹션 (동적 목록)
                    Text('조리법', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
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
                              child: Text('${index + 1}.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _stepControllers[index],
                                decoration: const InputDecoration(
                                  hintText: '예: 오븐을 180도로 예열합니다.',
                                ),
                                maxLines: null, // 여러 줄 입력 가능
                                keyboardType: TextInputType.multiline, // 멀티라인 키보드
                                validator: (value) { return null; },
                              ),
                            ),
                            // 삭제 버튼
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: colorScheme.error,
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
            );
              },
          ),
        ),
      ),
    );
  }
}
