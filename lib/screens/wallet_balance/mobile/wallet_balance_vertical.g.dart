import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/crypto_item_custom.dart';
import 'package:geniuswallet/widgets/symbols/crypto_item.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_menu.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_balance.g.dart';

class WalletBalanceVertical extends StatefulWidget {
  const WalletBalanceVertical() : super();
  @override
  _WalletBalanceVertical createState() => _WalletBalanceVertical();
}

class _WalletBalanceVertical extends State<WalletBalanceVertical> {
  _WalletBalanceVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 1.0,
          right: 0,
          top: 37.0,
          height: 280.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBalance(
              constraints,
              ovrCollectibles: 'Collectibles',
              ovrFinance: 'Finance',
              ovrLine: Image.asset(
                'assets/images/I0_52;0_12248.png',
                height: 19.000,
                width: 2.000,
              ),
              ovrTokens: 'Tokens',
            );
          }),
        ),
        Positioned(
          left: 48.25,
          right: 46.75,
          top: 340.5,
          height: 222.0,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.749,
              top: 0,
              height: 222.0,
              child: Container(
                height: 222.000,
                width: MediaQuery.of(context).size.width * 0.749,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 74.0,
              child: CryptoItemCustom(
                  child: LayoutBuilder(builder: (context, constraints) {
                return CryptoItem(
                  constraints,
                  ovrLine: Image.asset(
                    'assets/images/I0_49;0_12431.png',
                    height: MediaQuery.of(context).size.height * 0.002,
                    width: MediaQuery.of(context).size.width * 0.749,
                  ),
                  ovrEllipse: Image.asset(
                    'assets/images/I0_49;0_12432.png',
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: 36.774,
                  ),
                  ovr2099: '\$20.99',
                  ovr0BTC: '0.0065 ETH',
                  ovr418: '+5.25%',
                  ovr4630950: '\$3,218.64',
                  ovrCrypto: 'Ethereum',
                );
              })),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 74.0,
              height: 74.0,
              child: CryptoItemCustom(
                  child: LayoutBuilder(builder: (context, constraints) {
                return CryptoItem(
                  constraints,
                  ovrLine: Image.asset(
                    'assets/images/I0_50;0_12431.png',
                    height: MediaQuery.of(context).size.height * 0.002,
                    width: MediaQuery.of(context).size.width * 0.749,
                  ),
                  ovrEllipse: Image.asset(
                    'assets/images/I0_50;0_12432.png',
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: 36.774,
                  ),
                  ovr2099: ' ',
                  ovr0BTC: '0 BTC',
                  ovr418: '+4.18%',
                  ovr4630950: '\$46,309.50',
                  ovrCrypto: 'Bitcoin',
                );
              })),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 148.0,
              height: 74.0,
              child: CryptoItemCustom(
                  child: LayoutBuilder(builder: (context, constraints) {
                return CryptoItem(
                  constraints,
                  ovrLine: Image.asset(
                    'assets/images/I0_51;0_12431.png',
                    height: MediaQuery.of(context).size.height * 0.002,
                    width: MediaQuery.of(context).size.width * 0.749,
                  ),
                  ovrEllipse: Image.asset(
                    'assets/images/I0_51;0_12432.png',
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: 36.774,
                  ),
                  ovr2099: ' ',
                  ovr0BTC: '606.147 GNUS',
                  ovr418: ' ',
                  ovr4630950: ' ',
                  ovrCrypto: 'Genius Token',
                );
              })),
            ),
          ]),
        ),
        Positioned(
          left: 0,
          right: 1.0,
          bottom: 0,
          height: 77.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return Navbar(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: Image.asset(
                'assets/images/I0_54;0_12369.png',
                height: 28.500,
                width: 22.871,
              ),
              ovrDex: 'Dex',
              ovrsettings: 'settings',
              ovrEllipseXor: Image.asset(
                'assets/images/I0_54;0_12375.png',
                height: MediaQuery.of(context).size.height * 0.028,
                width: MediaQuery.of(context).size.width * 0.060,
              ),
            );
          }),
        ),
        Positioned(
          left: 0.544,
          right: 0.456,
          top: MediaQuery.of(context).size.height * 0.064,
          height: MediaQuery.of(context).size.height * 0.046,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationMenu(
              constraints,
            );
          }),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
