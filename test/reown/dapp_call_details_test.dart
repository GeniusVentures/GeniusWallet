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
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
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

// -- Real calldata, so what these cases pump is what a dApp would actually
// send. The drawer body is built from the summary the decoder returns, which
// is the only way a test can prove the threshold reaches the screen.
const _knownToken = '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB';
const _knownCoin = Coin(symbol: 'USDC', address: _knownToken, decimals: '6');

String _approveCalldata(String allowanceWord) =>
    '0x095ea7b3'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '$allowanceWord';

Map<String, dynamic> _tx(String data, {String value = '0x0'}) =>
    <String, dynamic>{
      'from': '0x0000000000000000000000000000000000000001',
      'to': _knownToken,
      'value': value,
      'data': data,
    };

/// A well-formed call to a function this wallet has no ABI for -- what a
/// router or an NFT marketplace actually sends, not malformed input.
const _unreadableCalldata =
    '0xdeadbeef'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

/// A transfer of 1500000 base units to the EIP-55 vector address.
const _transferCalldata =
    '0xa9059cbb'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

/// The drawer body `handle_dapp_requests` builds for [tx], assembled from the
/// same three functions it calls.
Widget _bodyFor(Map<String, dynamic> tx, {List<Coin> coins = const []}) {
  final summary = summarizeTransaction(tx, coins: coins);
  return DappCallDetails(
    headline: dappCallHeadline(summary),
    warning: dappCallWarning(summary),
    rows: dappCallRows(summary, networkName: 'Base', nativeSymbol: 'ETH'),
  );
}

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

  group('an approve, as the drawer actually assembles it', () {
    testWidgets('a max-uint256 allowance says so in words', (tester) async {
      await _openDrawer(
        tester,
        _bodyFor(_tx(_approveCalldata('f' * 64)), coins: const [_knownCoin]),
      );

      expect(_onScreen(tester, 'Approve spending'), isTrue);
      expect(
        _onScreen(tester, 'unlimited'),
        isTrue,
        reason: 'an allowance at the sentinel must be named as unlimited',
      );
      // Nothing moves on an approve, so nothing may read as a send.
      expect(find.textContaining('You send'), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('an ordinary allowance gets the ordinary caution', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        _bodyFor(
          _tx(_approveCalldata('${'0' * 58}16e360')),
          coins: const [_knownCoin],
        ),
      );

      expect(_onScreen(tester, 'Approve spending'), isTrue);
      expect(
        _onScreen(tester, 'unlimited'),
        isFalse,
        reason: 'a 1.5 USDC allowance must not be called unlimited',
      );
      expect(_onScreen(tester, '1.5 USDC'), isTrue);
      expect(find.textContaining('You send'), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('the spender is on screen and copies whole', (tester) async {
      await _openDrawer(
        tester,
        _bodyFor(
          _tx(_approveCalldata('${'0' * 58}16e360')),
          coins: const [_knownCoin],
        ),
      );

      await tester.tap(find.text('Spender'));
      await tester.pump();

      expect(copied, ['0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed']);

      await _closeDrawer(tester);
    });
  });

  group('a token this wallet cannot vouch for', () {
    testWidgets('the amount is a bare integer, never a guessed decimal', (
      tester,
    ) async {
      // No coins, so nothing resolves the contract. 1500000 base units at the
      // tempting eighteen-decimal default would render as 0.0000000000015.
      await _openDrawer(tester, _bodyFor(_tx(_transferCalldata)));

      expect(_onScreen(tester, 'Token transfer (unverified)'), isTrue);
      expect(find.textContaining('1500000'), findsOneWidget);
      expect(find.textContaining('0.0000000000015'), findsNothing);
      expect(find.textContaining('USDC'), findsNothing);

      // A decimal point anywhere in the figure would mean a decimals value was
      // assumed. It is also what would trip the send drawer's numeric allow-set.
      final figures = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((t) => t.contains('1500000'));
      for (final figure in figures) {
        expect(figure, isNot(contains('.')));
      }

      await _closeDrawer(tester);
    });

    testWidgets('the full contract address is there and copies whole', (
      tester,
    ) async {
      await _openDrawer(tester, _bodyFor(_tx(_transferCalldata)));

      await tester.tap(find.text('Token'));
      await tester.pump();

      expect(copied, [_knownToken]);

      await _closeDrawer(tester);
    });

    testWidgets('a token call that also moves native value shows BOTH', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        _bodyFor(
          _tx(_transferCalldata, value: '0x2386f26fc10000'),
          coins: const [_knownCoin],
        ),
      );

      // The token figure, in base units...
      expect(find.textContaining('1500000'), findsOneWidget);
      // ...and the native figure beside it, neither summarised away.
      expect(find.textContaining('0.0100000000 ETH'), findsOneWidget);

      await _closeDrawer(tester);
    });
  });

  group('a call this wallet could not read at all', () {
    testWidgets('it says so, and states only what it actually read', (
      tester,
    ) async {
      await _openDrawer(
        tester,
        _bodyFor(
          _tx(_unreadableCalldata, value: '0x2386f26fc10000'),
          coins: const [_knownCoin],
        ),
      );

      expect(_onScreen(tester, 'Unknown contract call'), isTrue);
      expect(_onScreen(tester, 'could not read'), isTrue);
      expect(_onScreen(tester, 'Contract'), isTrue);
      expect(_onScreen(tester, '0xdeadbeef'), isTrue);
      expect(_onScreen(tester, '0.0100000000 ETH'), isTrue);
      expect(_onScreen(tester, 'Base'), isTrue);

      await _closeDrawer(tester);
    });

    testWidgets('it is never dressed up as a send', (tester) async {
      // The failure this whole surface exists to prevent: an unreadable
      // payload presented as one figure leaving the wallet.
      await _openDrawer(
        tester,
        _bodyFor(_tx(_unreadableCalldata), coins: const [_knownCoin]),
      );

      expect(find.textContaining('You send'), findsNothing);
      expect(find.textContaining('You receive'), findsNothing);
      expect(find.textContaining('Gas Fee'), findsNothing);
      // The token the contract address happens to match is not what this
      // call was read to move -- nothing was read.
      expect(find.textContaining('USDC'), findsNothing);

      await _closeDrawer(tester);
    });

    testWidgets('the contract address copies whole', (tester) async {
      await _openDrawer(
        tester,
        _bodyFor(_tx(_unreadableCalldata), coins: const [_knownCoin]),
      );

      await tester.tap(find.text('Contract'));
      await tester.pump();

      expect(copied, [_knownToken]);

      await _closeDrawer(tester);
    });
  });
}
