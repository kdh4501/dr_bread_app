class UserEntity { // Entity는 특정 기술에 종속되지 않음
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  UserEntity({required this.uid, this.email, this.displayName, this.photoUrl});

// TODO: copyWith, toString 등 유용한 메서드 추가 가능
}