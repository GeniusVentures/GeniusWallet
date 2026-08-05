// Check for GWCopyRow (Phase 14 plan 03) - the promotion Phase 23 refused at
// two forks (`23-05-PLAN.md:155-166`), now approved because the bridge-hash
// row in plan 06 is the third occurrence of this exact shape. See this plan's
// SUMMARY for the reversal record.
//
// The one property that actually matters here: display truncation and
// clipboard content are separated by construction. A row that copied what it
// DISPLAYS would hand the user a corrupt hash that looks plausible - that is
// the failure T-14-09 names, and the "full value on the clipboard" assertion
// below compares against the untruncated input, not the rendered string, for
// exactly that reason.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _longValue = '0xabcdef0123456789abcdef0123456789abcdef01';
const _shortValue = '0x1234abcd';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: Scaffold(body: SizedBox(width: 380, child: child)),
);

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

  testWidgets('a long value renders truncated as its first six characters, an '
      'ellipsis, and its last six', (tester) async {
    await tester.pumpWidget(
      _host(const GWCopyRow(label: 'Hash', value: _longValue)),
    );

    // First six + "..." + last six, exactly the shipped fork's rule
    // (`token_info_screen.dart:999-1001`).
    expect(find.text('0xabcd...cdef01'), findsOneWidget);
    expect(find.text(_longValue), findsNothing);
  });

  testWidgets('a value short enough to fit renders whole, with no ellipsis', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const GWCopyRow(label: 'Hash', value: _shortValue)),
    );

    expect(find.text(_shortValue), findsOneWidget);
    expect(find.textContaining('...'), findsNothing);
  });

  testWidgets(
    'tapping the row places the FULL value on the clipboard, never the '
    'truncated form',
    (tester) async {
      await tester.pumpWidget(
        _host(const GWCopyRow(label: 'Hash', value: _longValue)),
      );

      await tester.tap(find.byType(GWCopyRow));
      await tester.pump();

      // Compared against the untruncated input, not the rendered string -
      // that is the assertion that actually pins the security property.
      expect(copied, [_longValue]);
    },
  );

  testWidgets('tapping raises a confirmation naming the row\'s own label', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const GWCopyRow(label: 'Bridge transaction', value: _longValue)),
    );

    await tester.tap(find.byType(GWCopyRow));
    await tester.pump();

    expect(find.text('Bridge transaction copied'), findsOneWidget);
  });

  testWidgets('the tap target fills the whole row, not just the glyph', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const GWCopyRow(label: 'Hash', value: _longValue)),
    );

    // Tap on the LABEL, at the row's far side from the copy glyph. If the
    // gesture detector only wrapped the glyph, this tap would land on
    // nothing tappable and the clipboard would stay empty.
    await tester.tap(find.text('Hash'));
    await tester.pump();

    expect(copied, [_longValue]);
  });
}
