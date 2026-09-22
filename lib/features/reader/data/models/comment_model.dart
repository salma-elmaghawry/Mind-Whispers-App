import 'package:mind_whispers_app/features/reader/data/models/author_ref_model.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';

class CommentModel {
  final int id;
  final int? parentId;
  final String content;
  final AuthorRefModel author;
  final List<CommentModel> replies;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    this.parentId,
    required this.content,
    required this.author,
    this.replies = const [],
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      content: json['content'] as String,
      author: json['author'] != null
          ? AuthorRefModel.fromJson(json['author'] as Map<String, dynamic>)
          : const AuthorRefModel(id: 0, name: ''),
      replies: (json['replies'] as List<dynamic>? ?? const [])
          .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      parentId: parentId,
      content: content,
      author: author.toEntity(),
      replies: replies.map((r) => r.toEntity()).toList(),
      createdAt: createdAt,
    );
  }
}
