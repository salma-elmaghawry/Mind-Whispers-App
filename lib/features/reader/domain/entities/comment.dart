import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';

/// Matches the `Comment` resource in API_CONTRACT.md.
class Comment extends Equatable {
  final int id;
  final String body;
  final AuthorRef author;
  final int postId;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.body,
    required this.author,
    required this.postId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, body, author, postId, createdAt];
}
