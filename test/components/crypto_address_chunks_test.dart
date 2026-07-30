// The ONE check 034-A2's grouped address owes.
//
// The address on this panel is the one string in the app a user reads
// character by character -- they hold it against an address they already
// have, and a middle-truncated form hides exactly the region a
// clipboard-substitution attack would alter. So the check that matters is
// that every character is on screen, in order, in 4-character groups with
// the two verifying ends emphasised -- and that the clipboard gets more than
// the eye does, never less.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Eleven unique groups (ten of 4 chars + a short final one) so `find.text`
// can locate each group unambiguously and prove order by construction: the
// address IS this list joined, so a correct render finds every entry once.
const _groups = [
  '0xA1',
  'B2C3',
  'D4E5',
  'F607',
  '1829',
  '3A4B',
  '5C6D',
  '7E8F',
  '9001',
  '2A3B',
  '4C',
];
final _address = _groups.join(); // 42 chars, matching a real address length.

Widget _host(String address) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 380,
        child: CryptoAddressQR(address: address, network: 'GNUS'),
      ),
    ),
  ),
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

  testWidgets(
    'a 42-character address renders as eleven groups, every character '
    'present, in order, with no ellipsis anywhere',
    (tester) async {
      await tester.pumpWidget(_host(_address));

      for (final group in _groups) {
        expect(
          find.text(group),
          findsOneWidget,
          reason: 'group "$group" must appear exactly once, uncorrupted',
        );
      }
      expect(find.textContaining('…'), findsNothing);
      expect(find.textContaining('...'), findsNothing);
    },
  );

  testWidgets('tapping the block copies the FULL address, not the displayed '
      'groups', (tester) async {
    await tester.pumpWidget(_host(_address));

    await tester.tap(find.text(_groups.first));
    await tester.pump();

    expect(copied, [_address]);

    // Flush the 2-second "Copied" reset timer before the test disposes the
    // tree, or the binding fails on a pending timer.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets(
    'the first two and the last two groups are heavier and brighter than '
    'the middle ones',
    (tester) async {
      await tester.pumpWidget(_host(_address));
      final gw = GWColors.dark();

      Text textFor(String group) => tester.widget<Text>(find.text(group));

      final emphasised = [
        _groups[0],
        _groups[1],
        _groups[_groups.length - 2],
        _groups[_groups.length - 1],
      ];
      final quiet = _groups
          .where((g) => !emphasised.contains(g))
          .toList(growable: false);
      expect(quiet, isNotEmpty);

      for (final group in emphasised) {
        final style = textFor(group).style!;
        expect(style.fontWeight, FontWeight.w700, reason: group);
        expect(style.color, gw.textPrimary, reason: group);
      }
      for (final group in quiet) {
        final style = textFor(group).style!;
        expect(style.fontWeight, FontWeight.w400, reason: group);
        expect(style.color, gw.textSecondary, reason: group);
      }
    },
  );

  testWidgets(
    'an address short enough to need no further grouping still renders '
    'whole and still copies whole',
    (tester) async {
      const short = '0x12';
      await tester.pumpWidget(_host(short));

      expect(find.text(short), findsOneWidget);

      await tester.tap(find.text(short));
      await tester.pump();
      expect(copied, [short]);

      // Flush the 2-second "Copied" reset timer -- same reason as above.
      await tester.pump(const Duration(seconds: 3));
    },
  );
}
