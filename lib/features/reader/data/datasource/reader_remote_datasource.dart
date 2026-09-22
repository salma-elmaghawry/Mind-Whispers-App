import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/comment_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/paginated_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/post_model.dart';

abstract class ReaderRemoteDataSource {
  Future<List<CategoryModel>> getCategories({String? search});

  Future<PaginatedModel<PostModel>> getPosts({
    String? search,
    String? categorySlug,
    int page = 1,
  });

  Future<PostModel> getPost(int id);

  Future<List<CommentModel>> getComments(int postId, {int page = 1});

  Future<CommentModel> addComment({required int postId, required String content, int? parentId});
}
