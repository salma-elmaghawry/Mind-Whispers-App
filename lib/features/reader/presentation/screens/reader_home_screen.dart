import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/widgets/adaptive_scaffold.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/explore_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/feed_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/notifications_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/profile_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/write_screen.dart';

/// The reader experience: Home (feed, search, category filters, trending),
/// Explore, Write (drafts/published), Notifications, and Profile. Post
/// detail and its comment thread are a separate pushed route (see
/// [PostDetailScreen] / `Routes.postDetail`), not a tab.
class ReaderHomeScreen extends StatelessWidget {
  const ReaderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedCubit>(
      create: (_) => getIt<FeedCubit>(),
      child: const _ReaderHomeView(),
    );
  }
}

class _ReaderHomeView extends StatefulWidget {
  const _ReaderHomeView();

  @override
  State<_ReaderHomeView> createState() => _ReaderHomeViewState();
}

class _ReaderHomeViewState extends State<_ReaderHomeView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdaptiveScaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: colorScheme.primary),
            horizontalSpace(8),
            Text('app_name'.tr()),
          ],
        ),
      ),
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: [
        AdaptiveDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'feed.tab_label'.tr(),
        ),
        AdaptiveDestination(
          icon: Icons.explore_outlined,
          selectedIcon: Icons.explore_rounded,
          label: 'explore.tab_label'.tr(),
        ),
        AdaptiveDestination(
          icon: Icons.add_rounded,
          label: 'write.tab_label'.tr(),
          iconWidget: _ComposeBadge(color: colorScheme.secondary),
          selectedIconWidget: _ComposeBadge(color: colorScheme.secondary),
        ),
        AdaptiveDestination(
          icon: Icons.notifications_none_rounded,
          selectedIcon: Icons.notifications_rounded,
          label: 'notifications.tab_label'.tr(),
        ),
        AdaptiveDestination(
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          label: 'profile.tab_label'.tr(),
        ),
      ],
      pages: const [
        FeedScreen(),
        ExploreScreen(),
        WriteScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ],
    );
  }
}

/// The raised purple "+" badge for the Write tab — the one destination in
/// the bar meant to read as an action ("compose") rather than a place.
class _ComposeBadge extends StatelessWidget {
  final Color color;

  const _ComposeBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
    );
  }
}
