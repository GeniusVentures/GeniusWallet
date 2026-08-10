// Check for GWPageHeader's trailing slot reaching the RIGHT EDGE of the header.
//
// The bug this file exists for (observed 2026-07-28 on `/news` and
// `/token-info` at ~1900px): the title row was
// `[Flexible(title), titleTrailing, Spacer(), trailing]`. `Flexible` and
// `Spacer` both default to flex 1, so the row's free space was split 50/50
// between them - and a LOOSE `Flexible` whose Text does not use its whole
// allowance leaves the remainder at the end of the row (default
// `MainAxisAlignment.start`). Result: "Updated now" stopped near the middle of
// a wide window while the search field below it spanned the full width.
//
// So the assertion is arithmetic on the laid-out geometry, not a golden.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';

/// Captured from inside the pumped tree so the expectations below read the
/// SAME inset the component applies, at the SAME breakpoint, rather than
/// restating a number that would silently disagree with it.
late double _inset;

Widget _host({Widget? leading, Widget? titleTrailing}) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: Builder(
        builder: (context) {
          _inset = gwPageHeaderContentInset(context);
          return GWPageHeader(
            title: 'Crypto News',
            leading: leading,
            titleTrailing: titleTrailing,
            trailing: const IconButton(
              onPressed: null,
              icon: Icon(Icons.refresh),
            ),
          );
        },
      ),
    ),
  ),
);

Widget _titleTrailing() => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const SizedBox(width: 6),
    Container(width: 1, height: 24, color: const Color(0xFF2A2A2A)),
    const SizedBox(width: 8),
    const SizedBox(width: 40, height: 40, child: Icon(Icons.qr_code)),
    const SizedBox(width: 40, height: 40, child: Icon(Icons.swap_horiz)),
  ],
);

void main() {
  testWidgets('trailing sits flush with the header right edge', (tester) async {
    await tester.pumpWidget(_host());

    final header = tester.getRect(find.byType(GWPageHeader));
    final trailing = tester.getRect(find.byType(IconButton));

    // A short title must not park the trailing widget mid-row.
    //
    // `- _inset` since 2026-08-08: the header now insets its identity row by
    // `gwPageHeaderContentInset` so page titles head their content column
    // instead of their container. "Flush" therefore means flush with the
    // header's CONTENT edge, which is the edge the body below the header uses.
    // The defect this file exists for - a trailing parked mid-row by a 50/50
    // flex split - would still be hundreds of pixels short of this.
    expect(
      trailing.right,
      moreOrLessEquals(header.right - _inset, epsilon: 0.5),
    );
  });

  testWidgets('flush with leading + titleTrailing, and never overflows', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // The coin page's title row: logo, name, hairline, action glyphs, price.
    for (final width in <double>[1900, 1200, 900, 768, 600, 360]) {
      await tester.binding.setSurfaceSize(Size(width, 600));
      await tester.pumpWidget(
        _host(
          leading: const SizedBox.square(dimension: 40),
          titleTrailing: _titleTrailing(),
        ),
      );

      expect(tester.takeException(), isNull, reason: 'overflow at $width');

      final header = tester.getRect(find.byType(GWPageHeader));
      final trailing = tester.getRect(find.byType(IconButton));
      expect(
        trailing.right,
        moreOrLessEquals(header.right - _inset, epsilon: 0.5),
        reason: 'trailing stopped short at $width',
      );

      // titleTrailing still rides the title's own line, immediately after it.
      final title = tester.getRect(find.text('Crypto News'));
      final hairline = tester.getRect(find.byType(Container).first);
      expect(hairline.left, greaterThanOrEqualTo(title.right));
      expect(hairline.left, lessThan(trailing.left));
    }
  });
}
