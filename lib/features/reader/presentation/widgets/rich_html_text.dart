import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    if (node is dom.Text) {
      final text = node.text.trim();
      if (text.isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(text, style: AppTextStyles.font18Normal),
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
          child: Text(text, style: AppTextStyles.font20Bold),
        );
      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _inlineText(context, node, AppTextStyles.font18Normal),
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
            AppTextStyles.font18Normal.copyWith(fontStyle: FontStyle.italic),
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
                      Text('•  ', style: AppTextStyles.font18Normal),
                      Expanded(child: _inlineText(context, item, AppTextStyles.font18Normal)),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'br':
        return const SizedBox(height: 8);
      default:
        final text = node.text.trim();
        if (text.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(text, style: AppTextStyles.font18Normal),
        );
    }
  }

  Widget _inlineText(BuildContext context, dom.Element element, TextStyle baseStyle) {
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
      visit(node, baseStyle);
    }

    return Text.rich(TextSpan(children: spans));
  }
}
