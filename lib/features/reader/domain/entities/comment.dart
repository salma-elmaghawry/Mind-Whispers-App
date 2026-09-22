import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';

class Comment extends Equatable {
  final int id;
  final int? parentId;
  final String content;
  final AuthorRef author;
  final List<Comment> replies;
  final DateTime createdAt;

  const Comment({
    required this.id,
    this.parentId,
    required this.content,
    required this.author,
    this.replies = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, parentId, content, author, replies, createdAt];
}
