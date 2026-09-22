import 'package:dartz/dartz.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/paginated.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

abstract class ReaderRepository {
  Future<Either<Failure, List<Category>>> getCategories({String? search});

  Future<Either<Failure, Paginated<Post>>> getPosts({
    String? search,
    String? categorySlug,
    int page = 1,
  });

  Future<Either<Failure, Post>> getPost(int id);

  Future<Either<Failure, List<Comment>>> getComments(int postId, {int page = 1});

  Future<Either<Failure, Comment>> addComment({
    required int postId,
    required String content,
    int? parentId,
  });
}
