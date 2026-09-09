import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_cover_image.dart';

/// A horizontal strip of cover-image thumbnails above the main feed list.
///
/// There's no `/trending` endpoint yet (see API_CONTRACT.md), so this just
/// re-surfaces the top of the already-fetched [posts] page as a lightweight
/// "what's popular" shelf — the same curation shortcut [RoleHomePlaceholder]
/// and `AuthorHomeScreen` take for features that haven't landed yet.
class TrendingRow extends StatelessWidget {
  final List<Post> posts;
  final ValueChanged<Post> onTap;

  const TrendingRow({super.key, required this.posts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('feed.trending_title'.tr(), style: Theme.of(context).textTheme.displaySmall),
        verticalSpace(12),
        SizedBox(
          height: 84.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            separatorBuilder: (_, _) => horizontalSpace(10),
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () => onTap(post),
                child: SizedBox(
                  width: 84.w,
                  child: PostCoverImage(
                    url: post.coverImageUrl,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
