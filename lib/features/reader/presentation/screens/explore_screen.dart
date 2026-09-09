import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/widgets/empty_state_view.dart';

/// The Explore tab of [ReaderHomeScreen]. Discovery (curated shelves,
/// author spotlights, category browsing beyond the feed's own filter chips)
/// isn't built yet — this holds the tab's place in the bottom nav so the
/// chrome matches the target design end to end.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.explore_outlined,
      title: 'explore.empty_title'.tr(),
      message: 'explore.empty_message'.tr(),
    );
  }
}
