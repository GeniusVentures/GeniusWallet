// Callers pass `network: selectedNetwork?.name ?? ''`, so a network without a
// name reaches the Receive drawer as an empty string. The warning is the one
// line between the user and a permanent loss of funds; it must stay a sentence.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _address = '0x1234567890abcdef1234567890abcdef12345678';

Widget _host(String network, {String? iconPath}) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.light()]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 380,
        child: CryptoAddressQR(
          address: _address,
          network: network,
          iconPath: iconPath,
        ),
      ),
    ),
  ),
);

void main() {
  for (final blank in ['', '   ']) {
    testWidgets('a blank network name ("$blank") keeps the warning a sentence '
        'and draws no empty chip', (tester) async {
      await tester.pumpWidget(_host(blank));

      expect(find.textContaining('-network'), findsNothing);
      expect(
        find.text('Only send assets on the selected network to this address.'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data ?? '').trim().isEmpty,
        ),
        findsNothing,
      );
    });
  }

  testWidgets('a named network is named in the warning and the chip', (
    tester,
  ) async {
    await tester.pumpWidget(_host('Ethereum'));

    expect(find.text('Ethereum'), findsOneWidget);
    expect(
      find.text('Only send Ethereum-network assets to this address.'),
      findsOneWidget,
    );
  });

  testWidgets('no icon means no embedded QR logo, not AssetImage("")', (
    tester,
  ) async {
    await tester.pumpWidget(_host('Ethereum'));

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.embeddedImage, isNull);
  });

  testWidgets('an empty icon path is treated as no icon', (tester) async {
    await tester.pumpWidget(_host('Ethereum', iconPath: ''));
    await tester.pumpAndSettle();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.embeddedImage, isNull);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
