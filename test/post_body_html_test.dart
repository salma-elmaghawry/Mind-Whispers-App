import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/rich_html_text.dart';

/// Regression guard for [RichHtmlText]: `PostResource.content` from the
/// live API (https://mind-whispers.laravel.cloud/api) is real HTML
/// (headings, paragraphs, a blockquote), not plain text — confirmed by
/// curling `GET /posts/12`. Before this widget existed, `PostDetailScreen`
/// rendered `content` as plain text, so this markup would have shown its
/// literal `<p>`/`<h2>` tags on screen instead of being rendered.
void main() {
  testWidgets('renders real post HTML content without throwing', (tester) async {
    const html =
        '<p>There is a version of this argument I have heard before, yet your '
        'framing made it feel new. Silence on the path made room for problems '
        'I had been avoiding indoors.</p>'
        '<p>In &quot;Walking Without a Podcast Changed How I Think&quot;, the '
        'question is not whether modern life is demanding.</p>'
        '<h2>A quieter way forward</h2>'
        '<p>There is a <strong>creative</strong> benefit too.</p>'
        '<blockquote>Attention is a form of respect, especially on the days '
        'when time feels scarce.</blockquote>';

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RichHtmlText(html: html))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The literal tags must not appear as visible text — proof the markup
    // was parsed and rendered, not dumped to screen verbatim.
    expect(find.textContaining('<p>'), findsNothing);
    expect(find.textContaining('<h2>'), findsNothing);
    // The decoded entity and the plain-text content should be on screen.
    expect(find.textContaining('A quieter way forward'), findsOneWidget);
    expect(find.textContaining('creative'), findsOneWidget);
  });
}
