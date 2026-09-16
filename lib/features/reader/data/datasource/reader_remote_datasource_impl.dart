import 'package:dio/dio.dart';
import 'package:mind_whispers_app/core/network/api_endpoints.dart';
import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource.dart';
import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/comment_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/paginated_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/post_model.dart';

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  final Dio _dio;

  ReaderRemoteDataSourceImpl(this._dio);

  List<dynamic> _asItemList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List<dynamic>;
    return const [];
  }

  
// categories
  @override
  Future<List<CategoryModel>> getCategories({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.categories,
      queryParameters: {if (search != null && search.isNotEmpty) 'q': search},
    );
    return _asItemList(response.data)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
//========================posts========================
  @override
  Future<PaginatedModel<PostModel>> getPosts({
    String? search,
    String? categorySlug,
    int page = 1,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.posts,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (categorySlug != null && categorySlug.isNotEmpty) 'category': categorySlug,
        'page': page,
      },
    );
    return PaginatedModel.fromJson(
      response.data as Map<String, dynamic>,
      PostModel.fromJson,
    );
  }
  // get post by id

  @override
  Future<PostModel> getPost(int id) async {
    final response = await _dio.get(ApiEndpoints.post(id));
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }
//========================comments========================
  @override
  Future<List<CommentModel>> getComments(int postId, {int page = 1}) async {
    final response = await _dio.get(
      ApiEndpoints.postComments(postId),
      queryParameters: {'page': page},
    );
    return _asItemList(response.data)
        .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  @override
  Future<CommentModel> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.postComments(postId),
      data: {'content': content, 'parent_id': ?parentId},
    );
    return CommentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
