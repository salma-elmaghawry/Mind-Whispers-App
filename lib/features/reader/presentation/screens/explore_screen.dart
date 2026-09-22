import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/core/widgets/coming_soon_screen.dart';
import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/category_chips_bar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_cover_image.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/relative_date.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const List<Category> _categories = [
    Category(id: 1, name: 'Fiction', slug: 'fiction', color: '#A78BFA'),
    Category(id: 2, name: 'Non-Fiction', slug: 'non-fiction', color: '#2E6F5B'),
    Category(id: 3, name: 'Self-Dev', slug: 'self-dev', color: '#B5793A'),
    Category(id: 4, name: 'Poetry', slug: 'poetry', color: '#E8547A'),
  ];

  static final List<_WriterSpotlight> _writers = [
    _WriterSpotlight(
      name: 'Maryam Eid',
      avatarUrl: 'https://ui-avatars.com/api/?name=Maryam+Eid&background=2E6F5B&color=fff',
      bio: 'Essays on slow living and the craft of writing.',
      followers: 128,
    ),
    _WriterSpotlight(
      name: 'Omar Farouk',
      avatarUrl: 'https://ui-avatars.com/api/?name=Omar+Farouk&background=A78BFA&color=fff',
      bio: 'Practical notes on habits, focus, and small routines.',
      followers: 94,
    ),
    _WriterSpotlight(
      name: 'Layla Haddad',
      avatarUrl: 'https://ui-avatars.com/api/?name=Layla+Haddad&background=6B4FBB&color=fff',
      bio: 'Short fiction about the rooms people leave behind.',
      followers: 211,
    ),
    _WriterSpotlight(
      name: 'Yusuf Kanaan',
      avatarUrl: 'https://ui-avatars.com/api/?name=Yusuf+Kanaan&background=B5793A&color=fff',
      bio: 'Long-form pieces on memory, archives, and language.',
      followers: 76,
    ),
  ];

  static final List<_PostSpotlight> _spotlights = [
    _PostSpotlight(
      title: 'On writing slowly',
      excerpt: 'Why the best sentences are the ones you were willing to throw away twice.',
      coverImageUrl: 'https://picsum.photos/seed/on-writing-slowly/400/400',
      categorySlug: 'non-fiction',
      authorName: 'Maryam Eid',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _PostSpotlight(
      title: 'The lighthouse keeper\'s daughter',
      excerpt: 'She counted the ships the way other children counted sheep.',
      coverImageUrl: 'https://picsum.photos/seed/lighthouse-keeper/400/400',
      categorySlug: 'fiction',
      authorName: 'Layla Haddad',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    _PostSpotlight(
      title: 'Five habits that quietly rebuilt my mornings',
      excerpt: 'None of them involve waking up at 5am, and that is the point.',
      coverImageUrl: 'https://picsum.photos/seed/morning-habits/400/400',
      categorySlug: 'self-dev',
      authorName: 'Omar Farouk',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _PostSpotlight(
      title: 'Instructions for leaving a small town',
      excerpt: 'A poem about the roads that only make sense once you\'re already gone.',
      coverImageUrl: 'https://picsum.photos/seed/leaving-small-town/400/400',
      categorySlug: 'poetry',
      authorName: 'Layla Haddad',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    _PostSpotlight(
      title: 'What the archive would not tell us',
      excerpt: 'A year spent in a basement of city records, looking for one missing name.',
      coverImageUrl: 'https://picsum.photos/seed/the-archive/400/400',
      categorySlug: 'non-fiction',
      authorName: 'Yusuf Kanaan',
      publishedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    _PostSpotlight(
      title: 'The productivity system that finally survived a bad week',
      excerpt: 'Every system works when things are calm. Here is the one that held anyway.',
      coverImageUrl: 'https://picsum.photos/seed/productivity-system/400/400',
      categorySlug: 'self-dev',
      authorName: 'Omar Farouk',
      publishedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  String? _selectedCategorySlug;

  List<_PostSpotlight> get _filteredSpotlights {
    final categorySlug = _selectedCategorySlug;
    if (categorySlug == null) return _spotlights;
    return _spotlights.where((post) => post.categorySlug == categorySlug).toList();
  }

  String _categoryName(String slug) => _categories.firstWhere((c) => c.slug == slug).name;

  void _openComingSoon(_PostSpotlight post) {
    context.pushNamed(
      Routes.comingSoon,
      arguments: ComingSoonArgs(
        title: post.title,
        message: 'explore.post_coming_soon'.tr(),
        icon: Icons.auto_stories_outlined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spotlights = _filteredSpotlights;

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      children: [
        Text('explore.title'.tr(), style: AppTextStyles.font20Bold).fadeInSlideUp(),
        verticalSpace(4),
        Text('explore.subtitle'.tr(), style: AppTextStyles.font14Normal.secondary(context)).fadeInSlideUp(delay: 40.ms),
        verticalSpace(16),
        CategoryChipsBar(
          categories: _categories,
          selectedCategorySlug: _selectedCategorySlug,
          onSelected: (slug) => setState(() => _selectedCategorySlug = slug),
        ),
        verticalSpace(24),
        Text('explore.writers_title'.tr(), style: AppTextStyles.font20Bold),
        verticalSpace(12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in _writers.asMap().entries) ...[
                  if (entry.key != 0) horizontalSpace(12),
                  SizedBox(
                    width: 180.w,
                    child: _WriterCard(writer: entry.value),
                  ).fadeInSlideUp(delay: (60 * entry.key).ms),
                ],
              ],
            ),
          ),
        ),
        verticalSpace(24),
        Text('explore.recommended_title'.tr(), style: AppTextStyles.font20Bold),
        verticalSpace(12),
        for (final entry in spotlights.asMap().entries)
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _SpotlightCard(
              post: entry.value,
              categoryName: _categoryName(entry.value.categorySlug),
              onTap: () => _openComingSoon(entry.value),
            ).fadeInSlideUp(delay: (40 * entry.key).ms),
          ),
      ],
    );
  }
}

class _WriterSpotlight {
  final String name;
  final String avatarUrl;
  final String bio;
  final int followers;

  _WriterSpotlight({
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.followers,
  });
}

class _PostSpotlight {
  final String title;
  final String excerpt;
  final String coverImageUrl;
  final String categorySlug;
  final String authorName;
  final DateTime publishedAt;

  _PostSpotlight({
    required this.title,
    required this.excerpt,
    required this.coverImageUrl,
    required this.categorySlug,
    required this.authorName,
    required this.publishedAt,
  });
}

class _WriterCard extends StatefulWidget {
  final _WriterSpotlight writer;

  const _WriterCard({required this.writer});

  @override
  State<_WriterCard> createState() => _WriterCardState();
}

class _WriterCardState extends State<_WriterCard> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final writer = widget.writer;
    final followers = writer.followers + (_following ? 1 : 0);

    return AppCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthorAvatar(name: writer.name, avatarUrl: writer.avatarUrl, radius: 22.r),
          verticalSpace(10),
          Text(
            writer.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font16SemiBold,
          ),
          verticalSpace(2),
          Text('explore.followers_count'.tr(args: ['$followers']), style: AppTextStyles.font12Medium.secondary(context)),
          verticalSpace(6),
          Text(
            writer.bio,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font12Medium.secondary(context),
          ),
          verticalSpace(10),
          _FollowButton(
            following: _following,
            onTap: () => setState(() => _following = !_following),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool following;
  final VoidCallback onTap;

  const _FollowButton({required this.following, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          backgroundColor: following ? colorScheme.secondary.withValues(alpha: 0.12) : null,
          side: BorderSide(color: following ? colorScheme.secondary : colorScheme.outlineVariant),
        ),
        child: Text(
          following ? 'explore.following'.tr() : 'explore.follow'.tr(),
          style: AppTextStyles.font12SemiBold.copyWith(
            color: following ? colorScheme.secondary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final _PostSpotlight post;
  final String categoryName;
  final VoidCallback onTap;

  const _SpotlightCard({required this.post, required this.categoryName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.all(10.w),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84.w,
            height: 84.w,
            child: PostCoverImage(
              url: post.coverImageUrl,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  categoryName,
                  style: AppTextStyles.font12SemiBold.copyWith(color: colorScheme.secondary),
                ),
                verticalSpace(4),
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font16SemiBold,
                ),
                verticalSpace(4),
                Text(
                  post.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font12Medium.secondary(context),
                ),
                verticalSpace(8),
                Row(
                  children: [
                    AuthorAvatar(name: post.authorName, radius: 9.r),
                    horizontalSpace(6),
                    Expanded(
                      child: Text(
                        post.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font12Medium.secondary(context),
                      ),
                    ),
                    Text(formatRelativeDate(post.publishedAt), style: AppTextStyles.font12Medium.secondary(context)),
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
