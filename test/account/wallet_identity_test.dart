import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

Wallet _eth(String name, String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: address,
);

const _addrA = '0x1111111111111111111111111111111111111111';
const _addrB = '0x2222222222222222222222222222222222222222';

Future<CircleAvatar> _pump(WidgetTester tester, Wallet wallet) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: themeFor(GWAppearanceMode.dark),
      home: AccountAvatar(
        wallet: wallet,
        isSelected: true,
        size: 32,
        showIdentity: true,
      ),
    ),
  );
  return tester.widget<CircleAvatar>(find.byType(CircleAvatar));
}

void main() {
  test('monogram rules, address-shaped names first', () {
    expect(walletMonogram('Super Genius Wallet 1'), 'S1');
    expect(walletMonogram('Super Genius Wallet 2'), 'S2');
    expect(walletMonogram('Wallet 10'), 'W10');
    expect(walletMonogram('Wallet 123'), 'W1');
    expect(walletMonogram('Main wallet'), 'MW');
    expect(walletMonogram('Savings'), 'SA');
    expect(walletMonogram('  '), isNull);
    expect(walletMonogram('0x7a3f9b2c0d3f6e21'), isNull);
    expect(
      walletMonogram('bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'),
      isNull,
    );
  });

  test('every identity fill meets AA with textOnBrand in both modes', () {
    for (final mode in GWAppearanceMode.values) {
      final gw = themeFor(mode).extension<GWColors>()!;
      for (final fill in GWColors.walletIdentityFills) {
        expect(contrastRatio(gw.textOnBrand, fill), greaterThanOrEqualTo(4.5));
        expect(
          contrastRatio(fill, gw.surfaceElevated),
          greaterThanOrEqualTo(3.0),
        );
      }
    }
  });

  testWidgets('two ETH wallets render different identities', (tester) async {
    // Pinned so a hash change, which would recolour every wallet, is noticed.
    expect(
      GWColors.walletIdentityFill(_addrA),
      GWColors.walletIdentityFills[0],
    );
    expect(
      GWColors.walletIdentityFill(_addrB),
      GWColors.walletIdentityFills[4],
    );
    expect(
      GWColors.walletIdentityFill(_addrA.toUpperCase()),
      GWColors.walletIdentityFill(_addrA),
    );
    expect(
      GWColors.walletIdentityFill(_addrA),
      isNot(GWColors.walletIdentityFill(_addrB)),
    );
    final a = await _pump(tester, _eth('Main wallet', _addrA));
    expect(find.text('MW'), findsOneWidget);
    final b = await _pump(tester, _eth('Savings', _addrB));
    expect(find.text('SA'), findsOneWidget);
    expect(a.backgroundColor, isNot(b.backgroundColor));
  });

  testWidgets('an address-shaped name falls back to the currency icon', (
    tester,
  ) async {
    await _pump(tester, _eth(_addrA, _addrA));
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}
