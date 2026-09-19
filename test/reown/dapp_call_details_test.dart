// The drawer content for everything a dApp transaction can be EXCEPT a plain
// send. It is the surface that has to admit what the wallet could not read, so
// the checks here are about honesty rather than looks:
//
//   - every string it is handed reaches the screen, unmodified,
//   - a value marked copyable puts the FULL string on the clipboard, never the
//     shortened form the row draws,
//   - it never grows a "You send" row or an amount hero -- the two things that
//     would turn an approval into a transfer in the user's head,
//   - and it renders in both appearances, because a caution nobody can read on
//     a light background is not a caution.
//
// Driven through a real `ApproveTransactionDrawer.show` and a real gesture,
// the way the drawer's own contract test does: this widget only ever ships
// inside that drawer, and a check that pumps it bare would not notice it
// breaking there.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/dapp_call_details.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _spender = '0xSpend01';
const _contract = '0xToken001';

const _headline = 'Approve spending';
const _warning = 'Double-check the spender before approving.';

const _fixture = DappCallDetails(
  headline: _headline,
  warning: _warning,
  rows: [
    DappCallRow(label: 'Spender', value: _spender, copyable: true),
    DappCallRow(label: 'Token', value: _contract, copyable: true),
    DappCallRow(label: 'Amount', value: '25 USDC'),
    DappCallRow(label: 'Network', value: 'Base'),
  ],
);

/// A value longer than `GWCopyRow`'s twelve-character truncation threshold, so
/// the string the row DRAWS and the string it must COPY are different.
const _fullAddress = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

/// Opens the transaction drawer around [content] through a real tap, in the
/// given appearance. Mirrors the drawer contract test's own harness -- never a
/// direct `Navigator.push`, because the route is part of what is under test.
Future<void> _openDrawer(
  WidgetTester tester,
  Widget content, {
  GWColors? colors,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ApproveTransactionDrawer.show(
              context: context,
              content: content,
              dappName: 'Uniswap',
              dappUrl: 'https://app.uniswap.org',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Leaves the route stack clean and lets any copy confirmation expire, so a
/// pending toast timer never leaks into the next case.
Future<void> _closeDrawer(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.tapAt(const Offset(10, 10));
  await tester.pumpAndSettle();
}

bool _onScreen(WidgetTester tester, String value) => tester
    .widgetList<Text>(find.byType(Text))
    .any((t) => (t.data ?? '').contains(value));

void main() {
  late List<String> copied;

  setUp(() {
    copied = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('DappCallDetails inside the transaction drawer', () {
    testWidgets('the headline, the warning and every row reach the screen', (
      tester,
    ) async {
      await _openDrawer(tester, _fixture);

      expect(_onScreen(tester, _headline), isTrue);
      expect(_onScreen(tester, _warning), isTrue);
      for (final row in _fixture.rows) {
        expect(
          _onScreen(tester, row.label),
          isTrue,
          reason: '"${row.label}" must be labelled on screen',
        );
        expect(
          _onScreen(tester, row.value),
          isTrue,
          reason: '"${row.value}" must reach the screen unmodified',
        );
      }

      await _closeDrawer(tester);
    });

    testWidgets('nothing here reads as a send -- no hero, no "You send" row', (
      tester,
    ) async {
      await _openDrawer(tester, _fixture);

      // The send body's own row label. If it ever appears here, an approval is
      // being described as money leaving the wallet, which it is not.
      expect(find.textContaining('You send'), findsNothing);
      expect(find.textContaining('Gas Fee'), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('a copyable row copies the FULL value, not the drawn form', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        const DappCallDetails(
          headline: _headline,
          warning: _warning,
          rows: [
            DappCallRow(label: 'Spender', value: _fullAddress, copyable: true),
          ],
        ),
      );

      // The row draws a shortened form; only the untruncated input proves the
      // clipboard did not receive it.
      expect(_onScreen(tester, _fullAddress), isFalse);

      await tester.tap(find.text('Spender'));
      await tester.pump();

      expect(copied, [_fullAddress]);

      await _closeDrawer(tester);
    });

    testWidgets('a row left uncopyable is a plain pair with no copy glyph', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        const DappCallDetails(
          headline: _headline,
          warning: _warning,
          rows: [DappCallRow(label: 'Amount', value: '25 USDC')],
        ),
      );

      expect(find.text('25 USDC'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('no rows renders the headline and warning and no empty frame', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        const DappCallDetails(headline: _headline, warning: _warning, rows: []),
      );

      expect(_onScreen(tester, _headline), isTrue);
      expect(_onScreen(tester, _warning), isTrue);
      expect(find.byType(GWDetailGrid), findsNothing);
      expect(find.text('DETAILS'), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('the same content renders in the light appearance', (
      tester,
    ) async {
      await _openDrawer(tester, _fixture, colors: GWColors.light());

      expect(_onScreen(tester, _headline), isTrue);
      expect(_onScreen(tester, _warning), isTrue);
      expect(tester.takeException(), isNull);

      await _closeDrawer(tester);
    });
  });
}
