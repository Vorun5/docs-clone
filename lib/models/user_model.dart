class UserModel {
  final String email;
  final String name;
  final String photoUrl;
  final String uid;
  final String token;

  UserModel({
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.uid,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'uid': uid,
        'token': token,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        uid: json['_id'] ?? '',
        token: json['token'] ?? '',
      );

  UserModel copyWith({
    String? email,
    String? name,
    String? photoUrl,
    String? uid,
    String? token,
  }) =>
      UserModel(
        email: email ?? this.email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        uid: uid ?? this.uid,
        token: token ?? this.token,
      );
}
