import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/widgets/empty_state_view.dart';
import 'package:mind_whispers_app/core/widgets/error_state_view.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/post.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_state.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/comment_composer.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/comment_tile.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_cover_image.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/relative_date.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/rich_html_text.dart';

/// A single post: cover, body, and its comment thread. `postId` comes from
/// the route arguments (see AppRouter) — [PostDetailCubit] fetches the post
/// and its comments fresh from `GET /posts/{post}` and
/// `GET /posts/{post}/comments` (see api-1.json).
class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostDetailCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      context.read<PostDetailCubit>().loadMoreComments();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// The comment is posted as whoever is signed in (the server reads the
  /// author off the Bearer token) — every route into this screen is
  /// already behind sign-in, so there's no signed-out case to guard here.
  void _handleAddComment(String content) {
    context.read<PostDetailCubit>().addComment(content: content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<PostDetailCubit, PostDetailState>(
          buildWhen: (previous, current) => previous.post != current.post,
          builder: (context, state) => Text(
            state.post?.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: BlocConsumer<PostDetailCubit, PostDetailState>(
        listenWhen: (previous, current) =>
            current.isFailure && current.action == PostDetailAction.addComment,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'errors.unexpected_error'.tr())),
          );
        },
        builder: (context, state) {
          if (state.status == Status.loading && state.post == null) {
            return _buildSkeleton();
          }
          if (state.isFailure && state.post == null) {
            return ErrorStateView(
              message: state.message ?? 'errors.unexpected_error'.tr(),
              onRetry: () => context.read<PostDetailCubit>().load(),
            );
          }

          final post = state.post;
          if (post == null) return const SizedBox.shrink();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: PostCoverImage(url: post.coverImageUrl),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.primaryCategory != null)
                            _CategoryChip(name: post.primaryCategory!.name),
                          verticalSpace(12),
                          Text(post.title, style: Theme.of(context).textTheme.displayMedium),
                          verticalSpace(14),
                          Row(
                            children: [
                              AuthorAvatar(
                                name: post.author.name,
                                avatarUrl: post.author.avatarUrl,
                                radius: 16.r,
                              ),
                              horizontalSpace(10),
                              Expanded(
                                child: Text(
                                  '${post.author.name} · ${formatRelativeDate(post.publishedAt ?? post.createdAt)}',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(22),
                          if (post.isLocked)
                            const _PremiumLockedNotice()
                          else
                            RichHtmlText(html: post.content ?? ''),
                          verticalSpace(28),
                          const Divider(),
                          verticalSpace(14),
                          Text(
                            'comments.title'.tr(args: ['${post.commentsCount}']),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          verticalSpace(8),
                          if (state.comments.isEmpty && !state.isLoadingMoreComments)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: state.commentsLoadFailed
                                  ? EmptyStateView(
                                      icon: Icons.error_outline_rounded,
                                      title: 'comments.load_error_title'.tr(),
                                      actionLabel: 'common.retry'.tr(),
                                      onAction: () =>
                                          context.read<PostDetailCubit>().retryLoadComments(),
                                    )
                                  : EmptyStateView(
                                      icon: Icons.mode_comment_outlined,
                                      title: 'comments.empty_title'.tr(),
                                    ),
                            )
                          else
                            for (final comment in state.comments) CommentTile(comment: comment),
                          if (state.isLoadingMoreComments)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              CommentComposer(
                isSubmitting: state.isSubmittingComment,
                onSubmit: _handleAddComment,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        AnimatedSkeleton(
          width: double.infinity,
          height: 200.h,
          borderRadius: BorderRadius.circular(16.r),
        ),
        verticalSpace(20),
        AnimatedSkeleton(width: 180.w, height: 20.h),
        verticalSpace(12),
        AnimatedSkeleton(width: double.infinity, height: 16.h),
        verticalSpace(8),
        AnimatedSkeleton(width: double.infinity, height: 16.h),
        verticalSpace(8),
        AnimatedSkeleton(width: 220.w, height: 16.h),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;

  const _CategoryChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}

/// Shown instead of the body for a premium [Post] the current caller can't
/// read yet (see [Post.isLocked]) — the API sends `content: null` rather
/// than a 403 for this case, so the app renders a lock state instead of an
/// error.
class _PremiumLockedNotice extends StatelessWidget {
  const _PremiumLockedNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: colorScheme.secondary),
          verticalSpace(10),
          Text('post.premium_locked_title'.tr(), style: textTheme.displaySmall),
          verticalSpace(6),
          Text('post.premium_locked_message'.tr(), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
