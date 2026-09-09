import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';

/// Matches the `Post` resource in API_CONTRACT.md.
class Post extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String body;
  final String excerpt;
  final String? coverImageUrl;
  final String status;
  final Category category;
  final AuthorRef author;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const Post({
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

  Post copyWith({int? commentsCount}) {
    return Post(
      id: id,
      title: title,
      slug: slug,
      body: body,
      excerpt: excerpt,
      coverImageUrl: coverImageUrl,
      status: status,
      category: category,
      author: author,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      publishedAt: publishedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    body,
    excerpt,
    coverImageUrl,
    status,
    category,
    author,
    commentsCount,
    createdAt,
    publishedAt,
  ];
}
