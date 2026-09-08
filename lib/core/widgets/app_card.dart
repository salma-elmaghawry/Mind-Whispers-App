import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';

/// The app's [Card] (uses AppTheme's cardTheme) with built-in tap feedback
/// when [onTap] is given — wrap post/user/category rows in this instead of
/// a bare Card so every tappable tile animates consistently.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(child: Padding(padding: padding, child: child));
    if (onTap == null) return card;
    return AnimatedTap(onTap: onTap, child: card);
  }
}
