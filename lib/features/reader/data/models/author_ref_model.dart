import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';

class AuthorRefModel {
  final int id;
  final String name;
  final String? avatarUrl;

  const AuthorRefModel({required this.id, required this.name, this.avatarUrl});

  factory AuthorRefModel.fromJson(Map<String, dynamic> json) {
    return AuthorRefModel(
      id: json['id'] as int,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  AuthorRef toEntity() => AuthorRef(id: id, name: name, avatarUrl: avatarUrl);
}
