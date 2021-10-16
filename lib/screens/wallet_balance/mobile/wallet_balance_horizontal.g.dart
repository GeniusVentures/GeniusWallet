import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/crypto_item.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_balance_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';

class WalletBalanceHorizontal extends StatefulWidget {
  const WalletBalanceHorizontal() : super();
  @override
  _WalletBalanceHorizontal createState() => _WalletBalanceHorizontal();
}

class _WalletBalanceHorizontal extends State<WalletBalanceHorizontal> {
  _WalletBalanceHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.062,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_288;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_288;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_288;0_12551.png',
              ovrAvatar: 'assets/images/I0_288;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.631,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_291;0_12431.png',
              ovrEllipse: 'assets/images/I0_291;0_12432.png',
              ovr2099: '\$20.99',
              ovr0BTC: '0.0065 ETH',
              ovr418: '+5.25%',
              ovr4630950: '\$3,218.64',
              ovrCrypto: 'Ethereum',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 0.999,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.754,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_292;0_12431.png',
              ovrEllipse: 'assets/images/I0_292;0_12432.png',
              ovr2099: ' ',
              ovr0BTC: '0 BTC',
              ovr418: '+4.18%',
              ovr4630950: '\$46,309.50',
              ovrCrypto: 'Bitcoin',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.877,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_293;0_12431.png',
              ovrEllipse: 'assets/images/I0_293;0_12432.png',
              ovr2099: ' ',
              ovr0BTC: '606.147 GNUS',
              ovr418: ' ',
              ovr4630950: ' ',
              ovrCrypto: 'Genius Token',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.324,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.467,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBalanceDesktop(
              constraints,
              ovrText: 'Main Wallet1',
              ovrAmount: '\$20.99',
              ovrCollectibles: 'Collectibles',
              ovrFinance: 'Finance',
              ovrLine: 'assets/images/I0_294;0_12741.png',
              ovrTokens: 'Tokens',
            );
          }),
        ),
        Positioned(
          left: 1321.8,
          width: 598.2,
          top: 540.9,
          height: 737.371,
          child: Image.asset(
            'assets/images/0_295.png',
            height: 737.371,
            width: 598.200,
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
