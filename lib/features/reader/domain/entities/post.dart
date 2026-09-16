import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/author_ref.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';

/// Matches the `PostResource` in api-1.json.
///
/// [content] is nullable on the wire itself: the API sends `null` for a
/// premium post's body when the caller has no premium access (no Bearer
/// token, or a token without an active Premium subscription/staff access).
/// [excerpt] is always shown regardless, so the UI can render a locked
/// state instead of a blank body — see `PostDetailScreen`.
///
/// [coverImageUrl] maps from the wire's `featured_image` (kept under this
/// name so `PostCoverImage`/`PostCard` don't need to change). A post can
/// belong to more than one [Category]; [primaryCategory] is the first one,
/// used anywhere the UI only has room for a single category badge.
class Post extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String? content;
  final String? coverImageUrl;
  final String status;
  final bool isPremium;
  final List<Category> categories;
  final AuthorRef author;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.coverImageUrl,
    required this.status,
    required this.isPremium,
    required this.categories,
    required this.author,
    required this.commentsCount,
    required this.createdAt,
    required this.publishedAt,
  });

  Category? get primaryCategory => categories.isNotEmpty ? categories.first : null;

  /// True when this post's full [content] is hidden from the current
  /// caller — i.e. a premium post fetched without premium access. Distinct
  /// from [isPremium]: a premium post the caller *can* read has content.
  bool get isLocked => isPremium && content == null;

  Post copyWith({int? commentsCount}) {
    return Post(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt,
      content: content,
      coverImageUrl: coverImageUrl,
      status: status,
      isPremium: isPremium,
      categories: categories,
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
    excerpt,
    content,
    coverImageUrl,
    status,
    isPremium,
    categories,
    author,
    commentsCount,
    createdAt,
    publishedAt,
  ];
}
