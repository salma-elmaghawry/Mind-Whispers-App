import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Renders a small, known subset of HTML — enough for a post's `content`
/// from the live API (headings, paragraphs, blockquotes, bold/italic text,
/// and lists; see `GET /posts/{post}` in api-1.json, whose `content` field
/// turned out to be real HTML rather than plain text). Not a
/// general-purpose HTML renderer: no images/iframes/tables.
///
/// Written by hand instead of pulling in a package for this because the
/// two obvious ones were a poor fit: `flutter_html` 3.0.0 fails to even
/// compile against this project's Dart SDK (a transitive `csslib`/`html`
/// version conflict — caught by `flutter test`, not `flutter analyze`),
/// and `flutter_widget_from_html` drags in ~55 transitive packages
/// (video_player, webview_flutter, url_launcher…) for content that never
/// needs any of them.
class RichHtmlText extends StatelessWidget {
  final String html;

  const RichHtmlText({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final body = html_parser.parse(html).body;
    if (body == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final node in body.nodes) ?_renderNode(context, node)],
    );
  }

  Widget? _renderNode(BuildContext context, dom.Node node) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (node is dom.Text) {
      final text = node.text.trim();
      if (text.isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(text, style: textTheme.bodyLarge),
      );
    }
    if (node is! dom.Element) return null;

    switch (node.localName) {
      case 'h1':
      case 'h2':
      case 'h3':
        final text = node.text.trim();
        if (text.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(text, style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
        );
      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _inlineText(context, node, textTheme.bodyLarge),
        );
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colorScheme.secondary, width: 3)),
          ),
          child: _inlineText(
            context,
            node,
            textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      case 'ul':
      case 'ol':
        final items = node.children.where((c) => c.localName == 'li');
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: textTheme.bodyLarge),
                      Expanded(child: _inlineText(context, item, textTheme.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'br':
        return const SizedBox(height: 8);
      default:
        // Unknown block element — render its text content plainly rather
        // than dropping it silently.
        final text = node.text.trim();
        if (text.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(text, style: textTheme.bodyLarge),
        );
    }
  }

  /// Builds one [Text.rich] for an element's inline content (bold/italic/
  /// links mixed with plain text) instead of flattening it to plain text.
  Widget _inlineText(BuildContext context, dom.Element element, TextStyle? baseStyle) {
    final colorScheme = Theme.of(context).colorScheme;
    final spans = <InlineSpan>[];

    void visit(dom.Node node, TextStyle style) {
      if (node is dom.Text) {
        if (node.text.isEmpty) return;
        spans.add(TextSpan(text: node.text, style: style));
        return;
      }
      if (node is! dom.Element) return;

      switch (node.localName) {
        case 'strong':
        case 'b':
          for (final child in node.nodes) {
            visit(child, style.copyWith(fontWeight: FontWeight.w700));
          }
        case 'em':
        case 'i':
          for (final child in node.nodes) {
            visit(child, style.copyWith(fontStyle: FontStyle.italic));
          }
        case 'a':
          for (final child in node.nodes) {
            visit(
              child,
              style.copyWith(color: colorScheme.secondary, decoration: TextDecoration.underline),
            );
          }
        case 'br':
          spans.add(const TextSpan(text: '\n'));
        default:
          for (final child in node.nodes) {
            visit(child, style);
          }
      }
    }

    for (final node in element.nodes) {
      visit(node, baseStyle ?? const TextStyle());
    }

    return Text.rich(TextSpan(children: spans));
  }
}
