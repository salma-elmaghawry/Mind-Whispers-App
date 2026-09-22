import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/rich_html_text.dart';

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
      ScreenUtilInit(
        designSize: const Size(800, 600),
        builder: (_, _) =>
            const MaterialApp(home: Scaffold(body: RichHtmlText(html: html))),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.textContaining('<p>'), findsNothing);
    expect(find.textContaining('<h2>'), findsNothing);

    expect(find.textContaining('A quieter way forward'), findsOneWidget);
    expect(find.textContaining('creative'), findsOneWidget);
  });
}
