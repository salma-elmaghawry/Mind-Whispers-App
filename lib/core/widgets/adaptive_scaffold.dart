import 'package:flutter/material.dart';

class AdaptiveDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const AdaptiveDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
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
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: destination.selectedIcon != null
                        ? Icon(destination.selectedIcon)
                        : null,
                    label: destination.label,
                  ),
              ],
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
                      icon: Icon(destination.icon),
                      selectedIcon: destination.selectedIcon != null
                          ? Icon(destination.selectedIcon)
                          : null,
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
