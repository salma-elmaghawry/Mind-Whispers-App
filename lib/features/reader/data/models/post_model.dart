import 'package:mind_whispers_app/features/reader/data/models/author_ref_model.dart';
import 'package:mind_whispers_app/features/reader/data/models/category_model.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';

/// Matches the `PostResource` in api-1.json.
///
/// `excerpt`, `featured_image`, `status`, `is_premium`, `published_at`, and
/// `created_at` are always present as keys on every endpoint that returns
/// this resource (some nullable). `author`, `categories`, and
/// `comments_count` are only *guaranteed* on the single-post endpoints
/// (`GET/POST/PATCH /posts/{post}`) — the list endpoints (`GET /posts`,
/// `GET /posts/manage`) don't add them to their required set, so they're
/// parsed defensively here rather than assumed present.
class PostModel {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String? content;
  final String? featuredImage;
  final String status;
  final bool isPremium;
  final List<CategoryModel> categories;
  final AuthorRefModel author;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const PostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.featuredImage,
    required this.status,
    required this.isPremium,
    required this.categories,
    required this.author,
    required this.commentsCount,
    required this.createdAt,
    required this.publishedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] as String?;
    final publishedAtRaw = json['published_at'] as String?;

    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String? ?? '',
      content: json['content'] as String?,
      featuredImage: json['featured_image'] as String?,
      status: json['status'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      author: json['author'] != null
          ? AuthorRefModel.fromJson(json['author'] as Map<String, dynamic>)
          : const AuthorRefModel(id: 0, name: ''),
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: createdAtRaw != null
          ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
          : DateTime.now(),
      publishedAt: publishedAtRaw != null ? DateTime.tryParse(publishedAtRaw) : null,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt,
      content: content,
      coverImageUrl: featuredImage,
      status: status,
      isPremium: isPremium,
      categories: categories.map((c) => c.toEntity()).toList(),
      author: author.toEntity(),
      commentsCount: commentsCount,
      createdAt: createdAt,
      publishedAt: publishedAt,
    );
  }
}
