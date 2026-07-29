// Check for the gap between GWPageHeader's title and its subtitle.
//
// The bug this file exists for (observed 2026-07-28 on `/token-info` at
// ~1900px): "GNUS · Ethereum" sat far under "GENIUS AI" instead of the 4px the
// component's own `SizedBox` asks for. Measured here before the fix: 19px.
//
// The spacer was never the problem. `trailing` used to live INSIDE the title
// Row, and on the coin page that trailing is a two-line price block ~62px
// tall. With `CrossAxisAlignment.center` the 32px title line box was centred
// in a 62px row, parking 15px of dead row under the title before the 4px
// spacer even started.
//
// So the assertion is arithmetic on the laid-out geometry, not a golden: the
// subtitle's line box starts `space2` under the title's line box no matter how
// tall `trailing` is. The one thing that legitimately still sits between them
// is `titleTrailing`'s own tap-target padding - a 48px WCAG target beside a
// 32px title line overhangs it by 8px top and bottom, and the last test pins
// the gap to exactly that and nothing more.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

const String _title = 'GENIUS AI';
const String _subtitle = 'GNUS  ·  Ethereum';

/// The coin page's own action targets: 48px, the size `GWButton.icon` renders
/// at `GWButtonSize.md`.
const double _tapTarget = 48;

/// The coin page's own trailing: a 28px price line over a percentage pill.
/// Deliberately taller than the title line box - that is the whole point.
Widget _priceBlock() => const Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('\$0.42', style: TextStyle(fontSize: 28, height: 34 / 28)),
    SizedBox(height: GeniusWalletConsts.space3),
    SizedBox(height: 22, width: 64),
  ],
);

Widget _titleTrailing() => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const SizedBox(width: GeniusWalletConsts.space6),
    Container(width: 1, height: 24, color: const Color(0xFF2A2A2A)),
    const SizedBox(width: GeniusWalletConsts.space4),
    const SizedBox.square(dimension: _tapTarget, child: Icon(Icons.qr_code)),
    const SizedBox.square(dimension: _tapTarget, child: Icon(Icons.swap_horiz)),
  ],
);

Widget _host({Widget? leading, Widget? titleTrailing, Widget? trailing}) =>
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: GWPageHeader(
            title: _title,
            subtitle: _subtitle,
            leading: leading,
            titleTrailing: titleTrailing,
            trailing: trailing,
          ),
        ),
      ),
    );

/// Vertical distance between the title's line box and the subtitle's.
double _gap(WidgetTester tester) =>
    tester.getRect(find.text(_subtitle)).top -
    tester.getRect(find.text(_title)).bottom;

void main() {
  testWidgets('subtitle sits space2 under a plain title', (tester) async {
    await tester.pumpWidget(_host());

    expect(_gap(tester), moreOrLessEquals(GeniusWalletConsts.space2));
  });

  testWidgets('a tall trailing does not push the subtitle down', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final width in <double>[1900, 1200, 900, 768, 600, 360]) {
      await tester.binding.setSurfaceSize(Size(width, 700));
      await tester.pumpWidget(
        _host(
          leading: const SizedBox.square(dimension: 40),
          trailing: _priceBlock(),
        ),
      );

      expect(tester.takeException(), isNull, reason: 'overflow at $width');
      expect(
        _gap(tester),
        moreOrLessEquals(GeniusWalletConsts.space2),
        reason: 'subtitle drifted from the title at $width',
      );
    }
  });

  // The full coin-page shape. `titleTrailing` rides the title's own line, so a
  // target taller than that line necessarily overhangs it - Material sizes a
  // tap target in layout, it has no way to reserve hit area outside its box.
  // Half the overhang lands under the title. Anything MORE than that is a
  // regression of the bug above.
  testWidgets('titleTrailing costs only its own tap-target padding', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final width in <double>[1900, 1200, 900, 768, 600, 360]) {
      await tester.binding.setSurfaceSize(Size(width, 700));
      await tester.pumpWidget(
        _host(
          leading: const SizedBox.square(dimension: 40),
          titleTrailing: _titleTrailing(),
          trailing: _priceBlock(),
        ),
      );

      expect(tester.takeException(), isNull, reason: 'overflow at $width');

      // Narrow windows wrap the title past 48px, at which point the title is
      // the taller child again and the overhang is gone entirely.
      final titleLine = tester.getRect(find.text(_title)).height;
      final overhang = ((_tapTarget - titleLine) / 2).clamp(0.0, _tapTarget);
      expect(
        _gap(tester),
        moreOrLessEquals(GeniusWalletConsts.space2 + overhang),
        reason: 'subtitle drifted from the title at $width',
      );
    }
  });
}
