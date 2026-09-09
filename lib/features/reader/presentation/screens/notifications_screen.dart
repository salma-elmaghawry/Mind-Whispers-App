import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/widgets/empty_state_view.dart';

/// The Notifications tab of [ReaderHomeScreen]. There's no notifications
/// backend yet (no `/notifications` endpoint in API_CONTRACT.md) — this
/// holds the tab's place in the bottom nav so the chrome matches the target
/// design end to end.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.notifications_none_rounded,
      title: 'notifications.empty_title'.tr(),
      message: 'notifications.empty_message'.tr(),
    );
  }
}
