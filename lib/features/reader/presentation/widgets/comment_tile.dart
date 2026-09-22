import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/comment.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/relative_date.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

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
                        style: AppTextStyles.font14Medium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(formatRelativeDate(comment.createdAt), style: AppTextStyles.font12Medium.secondary(context)),
                  ],
                ),
                verticalSpace(4),
                Text(comment.content, style: AppTextStyles.font16Normal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
