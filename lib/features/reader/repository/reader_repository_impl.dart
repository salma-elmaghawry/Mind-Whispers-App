import 'package:dartz/dartz.dart';
import 'package:mind_whispers_app/core/error_handling/error_mapper.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/paginated.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource _remoteDataSource;

  ReaderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories({String? search}) async {
    try {
      final models = await _remoteDataSource.getCategories(search: search);
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Paginated<Post>>> getPosts({
    String? search,
    String? categorySlug,
    int page = 1,
  }) async {
    try {
      final model = await _remoteDataSource.getPosts(
        search: search,
        categorySlug: categorySlug,
        page: page,
      );
      return Right(model.toEntity((postModel) => postModel.toEntity()));
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(int id) async {
    try {
      final model = await _remoteDataSource.getPost(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(int postId, {int page = 1}) async {
    try {
      final models = await _remoteDataSource.getComments(postId, page: page);
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    try {
      final model = await _remoteDataSource.addComment(
        postId: postId,
        content: content,
        parentId: parentId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
