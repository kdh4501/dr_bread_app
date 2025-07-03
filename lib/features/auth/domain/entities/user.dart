class UserEntity { // Entity는 특정 기술에 종속되지 않음
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];

// TODO: copyWith, toString 등 유용한 메서드 추가 가능
}