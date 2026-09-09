import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/core/widgets/empty_state_view.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/post_cover_image.dart';

enum _WriteStatus { draft, published }

class _WriteItem {
  final String title;
  final _WriteStatus status;
  final DateTime date;

  const _WriteItem({required this.title, required this.status, required this.date});
}

/// The Write tab of [ReaderHomeScreen]: a reader's own drafts and published
/// posts. There's no "my posts" endpoint yet — see `AuthorHomeScreen`'s own
/// placeholder note, this covers the same ground for the reader-facing "+"
/// tab — so this list is static sample data, not wired to any repository.
/// Composing a new post isn't built either; the FAB says so instead of
/// silently doing nothing.
class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  static final List<_WriteItem> _items = [
    _WriteItem(
      title: 'The Power of Small Habits',
      status: _WriteStatus.draft,
      date: DateTime(2025, 5, 12),
    ),
    _WriteItem(
      title: 'Letters I Never Sent',
      status: _WriteStatus.draft,
      date: DateTime(2025, 4, 28),
    ),
    _WriteItem(
      title: 'A New Perspective',
      status: _WriteStatus.published,
      date: DateTime(2025, 5, 10),
    ),
    _WriteItem(
      title: 'Books and Healing',
      status: _WriteStatus.published,
      date: DateTime(2025, 5, 6),
    ),
    _WriteItem(
      title: 'Finding My Voice',
      status: _WriteStatus.published,
      date: DateTime(2025, 5, 2),
    ),
  ];

  _WriteStatus _selected = _WriteStatus.draft;

  void _composeComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('write.compose_coming_soon'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((item) => item.status == _selected).toList();

    // No AppBar here — this is a tab inside [ReaderHomeScreen]'s
    // AdaptiveScaffold, which already renders the shared "Writiva" bar. A
    // second AppBar would stack a redundant header under it.
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('write.title'.tr(), style: Theme.of(context).textTheme.displaySmall),
                verticalSpace(14),
                _SegmentedTabs(
                  selected: _selected,
                  onChanged: (status) => setState(() => _selected = status),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.edit_note_rounded,
                    title: _selected == _WriteStatus.draft
                        ? 'write.empty_drafts_title'.tr()
                        : 'write.empty_published_title'.tr(),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => verticalSpace(12),
                    itemBuilder: (context, index) => _WriteTile(item: filtered[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _composeComingSoon,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final _WriteStatus selected;
  final ValueChanged<_WriteStatus> onChanged;

  const _SegmentedTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          _SegmentedTab(
            label: 'write.drafts_tab'.tr(),
            selected: selected == _WriteStatus.draft,
            onTap: () => onChanged(_WriteStatus.draft),
          ),
          _SegmentedTab(
            label: 'write.published_tab'.tr(),
            selected: selected == _WriteStatus.published,
            onTap: () => onChanged(_WriteStatus.published),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentedTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _WriteTile extends StatelessWidget {
  final _WriteItem item;

  const _WriteTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDraft = item.status == _WriteStatus.draft;
    final statusColor = isDraft ? AppColors.warning : colorScheme.secondary;
    final statusLabel = isDraft ? 'write.draft_status'.tr() : 'write.published_status'.tr();

    return AppCard(
      padding: EdgeInsets.all(10.w),
      child: Row(
        children: [
          SizedBox(
            width: 56.w,
            height: 56.w,
            child: PostCoverImage(
              url: null,
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
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                verticalSpace(4),
                Text(
                  '$statusLabel · ${DateFormat.yMMMd().format(item.date)}',
                  style: textTheme.labelMedium?.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
