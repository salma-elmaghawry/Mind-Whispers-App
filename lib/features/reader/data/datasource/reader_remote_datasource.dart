import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/comment_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/paginated_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/post_model.dart';

/// Talks to the read-side content endpoints in API_CONTRACT.md
/// (`/categories`, `/posts`, `/posts/{id}/comments`). Throws raw exceptions;
/// [ReaderRepositoryImpl] is the only layer that catches them.
///
/// [ReaderFakeDataSource] is the only implementation today — there's no
/// live backend for this yet (unlike auth's api-1.json). Swapping in a real
/// Dio-backed implementation later needs no changes above this interface.
abstract class ReaderRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<PaginatedModel<PostModel>> getPosts({
    int? categoryId,
    String? search,
    int page = 1,
  });

  Future<PostModel> getPost(int id);

  Future<PaginatedModel<CommentModel>> getComments(int postId, {int page = 1});

  Future<CommentModel> addComment({
    required int postId,
    required String body,
    required int authorId,
    required String authorName,
    String? authorAvatarUrl,
  });

  Future<void> deleteComment(int id);
}

/// Thrown by [ReaderFakeDataSource] for an id that doesn't exist — the fake
/// stand-in for a real backend's 404. [ReaderRepositoryImpl] maps this to
/// [NotFoundFailure] specifically, same as it would map a real 404.
class ResourceNotFoundException implements Exception {
  final String message;
  const ResourceNotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => message;
}
