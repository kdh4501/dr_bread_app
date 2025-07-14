// lib/features/recipe/domain/entities/recipe.dart
// Domain Layer의 순수한 레시피 데이터 모델 (특정 기술에 종속되지 않음)

class RecipeEntity {
  final String uid; // 레시피 고유 ID
  final String title; // 레시피 제목
  final String? description; // 간단 설명 (선택 사항)
  final List<String>? ingredients; // 재료 목록 (예: ["강력분 200g", "설탕 50g"])
  final List<String>? steps; // 조리법 단계 목록 (예: ["반죽을 섞는다.", "오븐에 굽는다."])
  final String? photoUrl; // 레시피 사진 URL (선택 사항)
  final String? category; // 카테고리 (예: "빵", "쿠키")
  final String? authorUid; // 작성자 UID (어떤 사용자가 작성했는지)
  final DateTime? createdAt; // 생성 날짜/시간
  final DateTime? updatedAt; // 마지막 수정 날짜/시간
  final List<String>? tags; // 태그 관리 기능 구현
  final bool? isFavorite; // 즐겨찾기 여부
  final double? averageRating; // 평균 평점
  final int? reviewCount; // 리뷰 개수

  // 생성자: 필요한 필드를 받아서 초기화
  RecipeEntity({
    required this.uid, // UID는 필수
    required this.title, // 제목은 필수
    this.description,
    this.ingredients,
    this.steps,
    this.photoUrl,
    this.category,
    this.authorUid,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.isFavorite,
    this.averageRating,
    this.reviewCount,
  });

  // TODO: 필요에 따라 데이터 복사(copyWith), toString, equality 연산자(==, hashCode) 등 추가 가능

  // 예시: 복사(copyWith) 메서드 (객체의 일부 필드만 변경하여 새로운 객체 생성 시 유용)
  RecipeEntity copyWith({
    String? uid,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? photoUrl,
    String? category,
    String? authorUid,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isFavorite,
    double? averageRating,
    int? reviewCount,
  }) {
    return RecipeEntity(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      authorUid: authorUid ?? this.authorUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    title,
    ingredients,
    steps,
    photoUrl,
    authorUid,
    createdAt,
    updatedAt,
    category,
    tags,
    isFavorite,
  ];
}
