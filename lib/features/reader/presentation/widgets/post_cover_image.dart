import 'package:flutter/material.dart';

class PostCoverImage extends StatelessWidget {
  final String? url;
  final BorderRadius? borderRadius;

  const PostCoverImage({super.key, required this.url, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fallback = Container(
      color: colorScheme.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_stories_outlined,
        size: 32,
        color: colorScheme.primary.withValues(alpha: 0.5),
      ),
    );

    final resolvedUrl = url;
    Widget image = resolvedUrl == null
        ? fallback
        : Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback,
            loadingBuilder: (context, child, progress) => progress == null ? child : fallback,
          );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
