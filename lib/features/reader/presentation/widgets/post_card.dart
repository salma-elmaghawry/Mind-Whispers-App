import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_cover_image.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // The API doesn't have a likes concept yet (see API_CONTRACT.md), so the
  // count shown here is a deterministic, per-session display value seeded
  // from the post id — not persisted, not real engagement data. Liking/
  // bookmarking only flips local UI state; neither survives a refresh.
  late bool _liked;
  late int _likeCount;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _liked = false;
    _likeCount = 40 + (widget.post.id * 37) % 460;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  void _toggleBookmark() => setState(() => _bookmarked = !_bookmarked);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final post = widget.post;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PostCoverImage(
                  url: post.coverImageUrl,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
              ),
              if (post.primaryCategory != null)
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      post.primaryCategory!.name,
                      style: textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displaySmall,
                ),
                verticalSpace(6),
                Text(
                  post.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
                verticalSpace(8),
                Text(
                  'By ${post.author.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium,
                ),
                verticalSpace(12),
                Row(
                  children: [
                    _IconCount(
                      icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: _liked ? AppColors.like : colorScheme.onSurface.withValues(alpha: 0.55),
                      count: _likeCount,
                      onTap: _toggleLike,
                    ),
                    horizontalSpace(16),
                    _IconCount(
                      icon: Icons.mode_comment_outlined,
                      iconColor: colorScheme.onSurface.withValues(alpha: 0.55),
                      count: post.commentsCount,
                      onTap: widget.onTap,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleBookmark,
                      child: Icon(
                        _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20.sp,
                        color: _bookmarked ? colorScheme.secondary : colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCount extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final VoidCallback onTap;

  const _IconCount({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          horizontalSpace(5),
          Text('$count', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
