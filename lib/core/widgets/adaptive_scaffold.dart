import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class AdaptiveDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

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
                          child: Column(mainAxisSize: MainAxisSize.min, children: railTrailing!),
                        ),
                      )
                    : null,
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: destination.iconWidget ?? Icon(destination.icon),
                      selectedIcon:
                          destination.selectedIconWidget ??
                          (destination.selectedIcon != null
                              ? Icon(destination.selectedIcon)
                              : null),
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
        height: 86,
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

  const _FloatingNavItem({required this.destination, required this.selected, required this.onTap});

  bool get _isCustomBadge => destination.iconWidget != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    final iconArea = _isCustomBadge
        ? AnimatedContainer(
            duration: _duration,
            curve: _curve,
            transform: Matrix4.translationValues(0, -8, 0),
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
          )
        : AnimatedContainer(
            duration: _duration,
            curve: _curve,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: color, size: 22),
              child: selected
                  ? (destination.selectedIconWidget ??
                        Icon(destination.selectedIcon ?? destination.icon))
                  : Icon(destination.icon),
            ),
          );

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconArea,
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: (selected ? AppTextStyles.font10Bold : AppTextStyles.font10Medium)
                    .copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
