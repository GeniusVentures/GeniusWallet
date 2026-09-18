// The receive side must not move when a route fails.
//
// A failed quote clears the receive amount, and the field then shows its
// em-dash placeholder instead of a TextField. The two branches sat in a
// `Flexible`, which sizes to the child: a TextField fills the row, a `Text`
// is as wide as one character. So the token selector jumped left the moment
// a swap errored — the amount had not changed, only what was drawn in it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _usdc = SwapToken(
  chainId: '8453',
  address: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
  name: 'USD Coin',
  symbol: 'USDC',
  decimals: 6,
);

/// The right edge of the token selector — the thing that visibly jumped.
Future<double> _selectorLeft(WidgetTester tester, String amount) async {
  final controller = TextEditingController(text: amount);
  addTearDown(controller.dispose);

  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: SwapField(
          label: 'You Receive',
          controller: controller,
          onChanged: (_) {},
          selectedToken: _usdc,
          isSelectingFrom: false,
          tokens: const [_usdc],
          onTokenSelected: (_) {},
          emptyPlaceholder: '—',
        ),
      ),
    ),
  );
  await tester.pump();

  return tester.getTopLeft(find.text('USDC')).dx;
}

void main() {
  testWidgets('the token selector holds its place when the amount clears', (
    tester,
  ) async {
    final withAmount = await _selectorLeft(tester, '12.338322');
    final cleared = await _selectorLeft(tester, '');

    // Same row, same width, same selector position. Before the fix the
    // cleared case sat hundreds of logical pixels to the left.
    expect(cleared, withAmount);
  });

  testWidgets('the placeholder is what renders when the amount clears', (
    tester,
  ) async {
    await _selectorLeft(tester, '');

    // Guards the test itself: if the placeholder branch stopped being taken,
    // the case above would compare two TextFields and pass for free.
    expect(find.text('—'), findsOneWidget);
  });
}
