import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class AdaptiveDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  /// Overrides the default `Icon(icon)`/`Icon(selectedIcon)` rendering with
  /// a custom widget — e.g. a filled circular badge for a "compose" tab
  /// that should stand out from the rest of the bar. [icon]/[selectedIcon]
  /// are still required as the rail's fallback and for tooling that reads
  /// destinations by [IconData].
  final Widget? iconWidget;
  final Widget? selectedIconWidget;

  const AdaptiveDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.iconWidget,
    this.selectedIconWidget,
  });
}

/// Bottom navigation on phones, a side [NavigationRail] on wide screens —
/// same destinations and pages, different chrome. Reader/Author tabs use
/// the narrow layout; the Admin web dashboard (Day 9) is where the rail
/// actually earns its keep.
class AdaptiveScaffold extends StatelessWidget {
  static const double wideBreakpoint = 600;

  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> pages;
  final PreferredSizeWidget? appBar;
  final List<Widget>? railTrailing;

  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.pages,
    this.appBar,
    this.railTrailing,
  }) : assert(destinations.length == pages.length),
       assert(destinations.length >= 2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= wideBreakpoint;
        final body = IndexedStack(index: selectedIndex, children: pages);

        if (!isWide) {
          return Scaffold(
            appBar: appBar,
            body: body,
            bottomNavigationBar: _FloatingNavBar(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                trailing: railTrailing != null
                    ? Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: railTrailing!,
                          ),
                        ),
                      )
                    : null,
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: destination.iconWidget ?? Icon(destination.icon),
                      selectedIcon:
                          destination.selectedIconWidget ??
                          (destination.selectedIcon != null ? Icon(destination.selectedIcon) : null),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

/// A floating, pill-indicator bottom bar — the "modern" replacement for a
/// stock Material [NavigationBar]. Selection is shown as a soft rounded
/// highlight that expands to fit an inline label, rather than a static
/// icon-over-label stack; the destination whose [AdaptiveDestination]
/// supplies a custom icon widget (e.g. the reader's raised "compose"
/// circle) renders that badge on its own, lifted slightly above the bar,
/// instead of getting the same pill treatment as an ordinary tab.
class _FloatingNavBar extends StatelessWidget {
  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _FloatingNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : colorScheme.shadow).withValues(
                alpha: isDark ? 0.35 : 0.10,
              ),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              _FloatingNavItem(
                destination: destinations[i],
                selected: i == selectedIndex,
                onTap: () {
                  if (i != selectedIndex) {
                    HapticFeedback.selectionClick();
                    onDestinationSelected(i);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 220);
  static const Curve _curve = Curves.easeOutCubic;

  final AdaptiveDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  /// A destination with its own icon widget (the compose "+" circle) reads
  /// as an action, not a place — it gets a lift instead of the shared
  /// pill/label treatment the plain icon destinations use.
  bool get _isCustomBadge => destination.iconWidget != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    if (_isCustomBadge) {
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: destination.label,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: _duration,
                curve: _curve,
                transform: Matrix4.translationValues(0, -6, 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: selected
                    ? (destination.selectedIconWidget ?? destination.iconWidget!)
                    : destination.iconWidget!,
              ),
            ),
          ),
        ),
      );
    }

    final icon = selected
        ? (destination.selectedIconWidget ?? Icon(destination.selectedIcon ?? destination.icon))
        : Icon(destination.icon);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: AnimatedContainer(
              duration: _duration,
              curve: _curve,
              padding: EdgeInsets.symmetric(horizontal: selected ? 10 : 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              // [Flexible] (rather than a fixed-size child) is what keeps
              // this safe with 5 destinations: the pill only ever gets the
              // width left over after its neighbors' fixed-width icons, so
              // without it a long label ("Notifications") — or even "Home"
              // on a narrow phone — can demand more than the row has and
              // overflow. AnimatedSize animates the reveal; Flexible caps
              // how far it's allowed to grow; ellipsis is the last resort
              // if even the capped width is still too tight.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme.merge(
                    data: IconThemeData(color: color, size: 22),
                    child: icon,
                  ),
                  if (selected)
                    Flexible(
                      child: AnimatedSize(
                        duration: _duration,
                        curve: _curve,
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 6),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
