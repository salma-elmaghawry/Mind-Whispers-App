import 'package:mind_whispers_app/features/reader/data/models/author_ref_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

/// Matches the `Post` resource in API_CONTRACT.md.
class PostModel {
  final int id;
  final String title;
  final String slug;
  final String body;
  final String excerpt;
  final String? coverImageUrl;
  final String status;
  final CategoryModel category;
  final AuthorRefModel author;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const PostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.body,
    required this.excerpt,
    required this.coverImageUrl,
    required this.status,
    required this.category,
    required this.author,
    required this.commentsCount,
    required this.createdAt,
    required this.publishedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      body: json['body'] as String,
      excerpt: json['excerpt'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      status: json['status'] as String,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      author: AuthorRefModel.fromJson(json['author'] as Map<String, dynamic>),
      commentsCount: json['comments_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      title: title,
      slug: slug,
      body: body,
      excerpt: excerpt,
      coverImageUrl: coverImageUrl,
      status: status,
      category: category.toEntity(),
      author: author.toEntity(),
      commentsCount: commentsCount,
      createdAt: createdAt,
      publishedAt: publishedAt,
    );
  }
}
