import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/relative_date.dart';

enum _NotificationType { like, comment, follow, mention, system }

class _NotificationItem {
  final _NotificationType type;
  final String? actorName;
  final String? actorAvatarUrl;
  final String message;
  final DateTime createdAt;
  bool read;

  _NotificationItem({
    required this.type,
    this.actorName,
    this.actorAvatarUrl,
    required this.message,
    required this.createdAt,
    this.read = false,
  });
}

/// The Notifications tab of [ReaderHomeScreen]. There's no `/notifications`
/// endpoint yet (see API_CONTRACT.md) — this list is static sample data,
/// not wired to any repository, the same placeholder approach `WriteScreen`
/// takes for "my posts". Tapping an item flips its own read state locally,
/// the same ephemeral, per-session UI state `PostCard` uses for like/
/// bookmark — nothing here is persisted or synced.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  DateTime _hoursAgo(int hours) => DateTime.now().subtract(Duration(hours: hours));

  late final List<_NotificationItem> _items = [
    _NotificationItem(
      type: _NotificationType.like,
      actorName: 'Layla Haddad',
      actorAvatarUrl: 'https://ui-avatars.com/api/?name=Layla+Haddad&background=6B4FBB&color=fff',
      message: 'Layla Haddad liked your post "On writing slowly".',
      createdAt: _hoursAgo(2),
    ),
    _NotificationItem(
      type: _NotificationType.comment,
      actorName: 'Omar Farouk',
      actorAvatarUrl: 'https://ui-avatars.com/api/?name=Omar+Farouk&background=A78BFA&color=fff',
      message:
          'Omar Farouk commented on "Five habits that quietly rebuilt my mornings": '
          '"This stayed with me longer than I expected it to."',
      createdAt: _hoursAgo(20),
    ),
    _NotificationItem(
      type: _NotificationType.follow,
      actorName: 'Yusuf Kanaan',
      actorAvatarUrl: 'https://ui-avatars.com/api/?name=Yusuf+Kanaan&background=B5793A&color=fff',
      message: 'Yusuf Kanaan started following you.',
      createdAt: _hoursAgo(48),
      read: true,
    ),
    _NotificationItem(
      type: _NotificationType.system,
      message: 'Your post "A short poem for the second cup of coffee" was published.',
      createdAt: _hoursAgo(3),
      read: true,
    ),
    _NotificationItem(
      type: _NotificationType.mention,
      actorName: 'Maryam Eid',
      actorAvatarUrl: 'https://ui-avatars.com/api/?name=Maryam+Eid&background=2E6F5B&color=fff',
      message: 'Maryam Eid mentioned you in a comment on "Letters we never sent".',
      createdAt: _hoursAgo(70),
    ),
    _NotificationItem(
      type: _NotificationType.system,
      message: 'Weekly digest: 5 new posts were published in Self-Dev this week.',
      createdAt: _hoursAgo(140),
      read: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.read = true;
      }
    });
  }

  void _markRead(_NotificationItem item) {
    if (item.read) return;
    setState(() => item.read = true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasUnread = _items.any((item) => !item.read);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      children: [
        Row(
          children: [
            Expanded(child: Text('notifications.title'.tr(), style: textTheme.displaySmall)),
            TextButton(
              onPressed: hasUnread ? _markAllRead : null,
              child: Text('notifications.mark_all_read'.tr()),
            ),
          ],
        ),
        verticalSpace(8),
        for (final entry in _items.asMap().entries)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _NotificationTile(
              item: entry.value,
              onTap: () => _markRead(entry.value),
            ).fadeInSlideUp(delay: (30 * entry.key).ms),
          ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  IconData get _icon => switch (item.type) {
    _NotificationType.like => Icons.favorite_rounded,
    _NotificationType.comment => Icons.mode_comment_rounded,
    _NotificationType.follow => Icons.person_add_rounded,
    _NotificationType.mention => Icons.alternate_email_rounded,
    _NotificationType.system => Icons.campaign_rounded,
  };

  Color _iconColor(ColorScheme colorScheme) => switch (item.type) {
    _NotificationType.like => AppColors.like,
    _NotificationType.comment => colorScheme.secondary,
    _NotificationType.follow => colorScheme.primary,
    _NotificationType.mention => AppColors.info,
    _NotificationType.system => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final actorName = item.actorName;
    final actorAvatarUrl = item.actorAvatarUrl;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actorName != null)
            AuthorAvatar(name: actorName, avatarUrl: actorAvatarUrl, radius: 20.r)
          else
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: _iconColor(colorScheme).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(_icon, size: 20.sp, color: _iconColor(colorScheme)),
            ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: item.read ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                verticalSpace(4),
                Text(formatRelativeDate(item.createdAt), style: textTheme.labelSmall),
              ],
            ),
          ),
          if (!item.read) ...[
            horizontalSpace(8),
            Container(
              width: 8.r,
              height: 8.r,
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
