import 'package:flutter/material.dart';

/// A network avatar with a graceful initials fallback — used for post
/// authors and commenters, neither of which are guaranteed an `avatar_url`.
class AuthorAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;

  const AuthorAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final url = avatarUrl;

    if (url == null || url.isEmpty) {
      return _initialsCircle(context, size);
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _initialsCircle(context, size),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _initialsCircle(context, size);
        },
      ),
    );
  }

  Widget _initialsCircle(BuildContext context, double size) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: size * 0.38,
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
