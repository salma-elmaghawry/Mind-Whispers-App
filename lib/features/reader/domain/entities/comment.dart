import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';

/// Matches the `CommentResource` in api-1.json: `{ id, parent_id, content,
/// author, replies, created_at }`. There's no `post_id` on the wire — every
/// comment is already scoped to one post by the endpoint it came from
/// (`GET/POST /posts/{post}/comments`), so callers track that separately
/// instead of reading it off the comment itself.
///
/// [replies] holds the direct replies to a top-level comment (the API only
/// supports one level: a reply's `parent_id` must point at a top-level
/// comment on the same post), each carrying its own [author] but normally
/// an empty `replies` list of its own.
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
