import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/widgets/app_text_field.dart';
import 'package:mind_whispers_app/core/widgets/empty_state_view.dart';
import 'package:mind_whispers_app/core/widgets/error_state_view.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_state.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/category_chips_bar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_card.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/trending_row.dart';

/// The Feed tab of [ReaderHomeScreen]: search, category filter, a trending
/// shelf, and an infinite-scroll list of published posts (see
/// API_CONTRACT.md's `/posts` and `/categories`, served today by
/// [ReaderFakeDataSource]).
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const int _trendingCount = 6;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FeedCubit>().loadInitial();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      context.read<FeedCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        if (state.isInitialLoad) {
          return _buildSkeleton();
        }
        if (state.isFailure && state.posts.isEmpty && state.categories.isEmpty) {
          return ErrorStateView(
            message: state.message ?? 'errors.unexpected_error'.tr(),
            onRetry: () => context.read<FeedCubit>().loadInitial(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<FeedCubit>().refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 4.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _searchController,
                        label: 'feed.search_label'.tr(),
                        hint: 'feed.search_hint'.tr(),
                        prefixIcon: const Icon(Icons.search_rounded),
                        onChanged: (value) => context.read<FeedCubit>().search(value),
                      ),
                      verticalSpace(14),
                      CategoryChipsBar(
                        categories: state.categories,
                        selectedCategoryId: state.selectedCategoryId,
                        onSelected: (id) => context.read<FeedCubit>().selectCategory(id),
                      ),
                      if (state.posts.isNotEmpty) ...[
                        verticalSpace(20),
                        TrendingRow(
                          posts: state.posts.take(_trendingCount).toList(),
                          onTap: (post) => context.pushNamed(Routes.postDetail, arguments: post.id),
                        ),
                      ],
                      verticalSpace(4),
                    ],
                  ),
                ),
              ),
              if (state.posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'feed.empty_title'.tr(),
                    message: 'feed.empty_message'.tr(),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList.separated(
                    itemCount: state.posts.length,
                    separatorBuilder: (context, index) => verticalSpace(16),
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        post: post,
                        onTap: () => context.pushNamed(Routes.postDetail, arguments: post.id),
                      ).fadeInSlideUp(delay: (30 * (index % 6)).ms);
                    },
                  ),
                ),
              if (state.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              SliverToBoxAdapter(child: verticalSpace(20)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      separatorBuilder: (context, index) => verticalSpace(16),
      itemBuilder: (context, index) => AnimatedSkeleton(
        width: double.infinity,
        height: 260.h,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
