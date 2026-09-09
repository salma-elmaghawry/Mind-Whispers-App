import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
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
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await _remoteDataSource.getCategories();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Paginated<Post>>> getPosts({
    int? categoryId,
    String? search,
    int page = 1,
  }) async {
    try {
      final model = await _remoteDataSource.getPosts(
        categoryId: categoryId,
        search: search,
        page: page,
      );
      return Right(model.toEntity((postModel) => postModel.toEntity()));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(int id) async {
    try {
      final model = await _remoteDataSource.getPost(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Paginated<Comment>>> getComments(
    int postId, {
    int page = 1,
  }) async {
    try {
      final model = await _remoteDataSource.getComments(postId, page: page);
      return Right(model.toEntity((commentModel) => commentModel.toEntity()));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required int postId,
    required String body,
    required int authorId,
    required String authorName,
    String? authorAvatarUrl,
  }) async {
    try {
      final model = await _remoteDataSource.addComment(
        postId: postId,
        body: body,
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(int id) async {
    try {
      await _remoteDataSource.deleteComment(id);
      return const Right(unit);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  /// [ErrorMapper] only understands Dio/IO exceptions; the fake datasource
  /// signals a missing id with [ResourceNotFoundException] instead, so it's
  /// translated to the same [NotFoundFailure] a real 404 would produce.
  Failure _mapError(Object error) {
    if (error is ResourceNotFoundException) {
      return NotFoundFailure(message: 'errors.not_found'.tr());
    }
    return ErrorMapper.map(error);
  }
}
