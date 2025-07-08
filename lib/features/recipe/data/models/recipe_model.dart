// TODO: RecipeModel 클래스에 toEntity() 및 fromEntity() 메서드/팩토리 추가 필요

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recipe.dart';

class RecipeModel { // RecipeEntity 상속 또는 필드 복사
  // Firestore에서 사용하는 필드 이름과 타입에 맞게 정의
  final String id; // Firestore 문서 ID
  final String title;
  final String? description;
  final List<String>? ingredients;
  final List<String>? steps;
  final String? photoUrl;
  final String? category;
  final String? authorUid;
  final Timestamp? createdAt; // Firestore Timestamp
  final Timestamp? updatedAt; // Firestore Timestamp
  final List<String>? tags;
  final bool? isFavorite;

  RecipeModel({
    required this.id,
    required this.title,
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
  });

  // Firestore Map 데이터로부터 RecipeModel 객체 생성 (fromJson)
  factory RecipeModel.fromJson(Map<String, dynamic> json, String id) {
    return RecipeModel(
      id: id, // 문서 ID는 Map 데이터에 포함되지 않으므로 별도로 받음
      title: json['title'] as String,
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e as String).toList(),
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList(),
      photoUrl: json['photoUrl'] as String?,
      category: json['category'] as String?,
      authorUid: json['authorUid'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isFavorite: json['isFavorite'] as bool?,
    );
  }

  // RecipeModel 객체를 Firestore 저장을 위한 Map 데이터로 변환 (toJson)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'photoUrl': photoUrl,
      'category': category,
      'authorUid': authorUid,
      'createdAt': createdAt ?? Timestamp.now(), // 생성 시 Timestamp 자동 설정
      'updatedAt': Timestamp.now(), // 업데이트 시 Timestamp 자동 설정
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  // RecipeModel 객체를 Domain Layer의 RecipeEntity 객체로 변환 (toEntity)
  RecipeEntity toEntity() {
    return RecipeEntity(
      uid: id,
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      photoUrl: photoUrl,
      category: category,
      authorUid: authorUid,
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
      tags: tags,
      isFavorite: isFavorite,
    );
  }

  // Domain Layer의 RecipeEntity 객체로부터 RecipeModel 객체 생성 (fromEntity)
  factory RecipeModel.fromEntity(RecipeEntity entity) {
    return RecipeModel(
      id: entity.uid, // Entity의 UID를 Model의 ID로 사용
      title: entity.title,
      description: entity.description,
      ingredients: entity.ingredients,
      steps: entity.steps,
      photoUrl: entity.photoUrl,
      category: entity.category,
      authorUid: entity.authorUid,
      createdAt: entity.createdAt != null ? Timestamp.fromDate(entity.createdAt!) : null,
      updatedAt: entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
      tags: entity.tags,
      isFavorite: entity.isFavorite,
    );
  }
}