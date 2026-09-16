import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/relative_date.dart';

/// Renders one comment and, indented beneath it, its direct [Comment.replies]
/// — the API only nests one level deep, so this never recurses further than
/// that in practice. There's no delete-comment endpoint in api-1.json, so
/// unlike the old fake-backed version of this tile there's no delete action.
class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(context, comment),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsetsDirectional.only(start: 36.w),
            child: Column(
              children: [for (final reply in comment.replies) CommentTile(comment: reply)],
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, Comment comment) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorAvatar(name: comment.author.name, avatarUrl: comment.author.avatarUrl, radius: 16.r),
          horizontalSpace(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.author.name,
                        style: textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(formatRelativeDate(comment.createdAt), style: textTheme.labelMedium),
                  ],
                ),
                verticalSpace(4),
                Text(comment.content, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
