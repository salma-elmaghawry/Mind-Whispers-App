import 'package:mind_whispers_app/features/reader/data/models/author_ref_model.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';

class CommentModel {
  final int id;
  final String body;
  final AuthorRefModel author;
  final int postId;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.body,
    required this.author,
    required this.postId,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      body: json['body'] as String,
      author: AuthorRefModel.fromJson(json['author'] as Map<String, dynamic>),
      postId: json['post_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      body: body,
      author: author.toEntity(),
      postId: postId,
      createdAt: createdAt,
    );
  }
}
